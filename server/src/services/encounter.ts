import type pg from 'pg';
import { verifyEncounterJwt } from '../security/jwt-verify.js';
import { logger } from '../config/logger.js';
import * as errors from '../utils/errors.js';

export interface EncounterRow {
  id: string;
  initiator_id: string;
  receiver_id: string;
  encounter_token: string;
  latitude: number | null;
  longitude: number | null;
  encountered_at: string;
  verified_at: string;
}

/**
 * Verify an encounter JWT and record it.
 *
 * Flow:
 *   1. Verify JWT signature + TTL (ES256, max 300s)
 *   2. Check jti not already used (replay prevention)
 *   3. Validate both memberships exist and are not revoked
 *   4. Insert encounter record
 */
export async function verifyAndRecordEncounter(
  client: pg.PoolClient,
  token: string,
): Promise<EncounterRow> {
  // 1. Verify JWT
  let claims;
  try {
    claims = await verifyEncounterJwt(token);
  } catch (err) {
    const message = err instanceof Error ? err.message : 'JWT verification failed';
    throw errors.unauthorized(`Encounter verification failed: ${message}`);
  }

  // 2. Replay check
  const { rows: existing } = await client.query(
    'SELECT id FROM encounters WHERE encounter_token = $1',
    [claims.jti],
  );
  if (existing.length > 0) {
    throw errors.conflict('Encounter already recorded (replay)');
  }

  // 3. Validate memberships
  const { rows: initiator } = await client.query(
    'SELECT id FROM memberships WHERE id = $1 AND revoked = FALSE',
    [claims.sub],
  );
  if (initiator.length === 0) {
    throw errors.unauthorized('Initiator membership not found or revoked');
  }

  const { rows: receiver } = await client.query(
    'SELECT id FROM memberships WHERE id = $1 AND revoked = FALSE',
    [claims.aud],
  );
  if (receiver.length === 0) {
    throw errors.unauthorized('Receiver membership not found or revoked');
  }

  // 4. Record
  const encounteredAt = new Date(claims.iat * 1000).toISOString();
  const { rows } = await client.query<EncounterRow>(
    `INSERT INTO encounters (initiator_id, receiver_id, encounter_token, latitude, longitude, encountered_at)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [
      claims.sub,
      claims.aud,
      claims.jti,
      claims.lat ?? null,
      claims.lng ?? null,
      encounteredAt,
    ],
  );

  const encounter = rows[0]!;
  logger.info(
    {
      encounterId: encounter.id,
      initiator: claims.sub,
      receiver: claims.aud,
    },
    'Encounter verified and recorded',
  );

  return encounter;
}
