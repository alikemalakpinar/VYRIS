import { importSPKI, jwtVerify, type CryptoKey as JoseCryptoKey } from 'jose';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';

let cachedKey: JoseCryptoKey | null = null;

async function getPublicKey(): Promise<JoseCryptoKey> {
  if (cachedKey) return cachedKey;

  const pem = env.ENCOUNTER_JWT_PUBLIC_KEY;
  cachedKey = await importSPKI(pem, 'ES256');
  return cachedKey;
}

export interface EncounterClaims {
  /** JWT ID — unique encounter token, used for replay prevention */
  jti: string;
  /** Initiator membership ID */
  sub: string;
  /** Receiver membership ID */
  aud: string;
  /** Issued at (epoch seconds) */
  iat: number;
  /** Location (optional) */
  lat?: number;
  lng?: number;
}

/**
 * Verify an encounter JWT signed with ES256.
 * Returns decoded claims or throws.
 */
export async function verifyEncounterJwt(
  token: string,
  maxAgeSec: number = 300,
): Promise<EncounterClaims> {
  const key = await getPublicKey();

  const { payload } = await jwtVerify(token, key, {
    algorithms: ['ES256'],
    maxTokenAge: `${maxAgeSec}s`,
  });

  if (!payload.jti || !payload.sub || !payload.aud) {
    throw new Error('Missing required JWT claims (jti, sub, aud)');
  }

  const aud = Array.isArray(payload.aud) ? payload.aud[0] : payload.aud;
  if (!aud) {
    throw new Error('Missing aud claim');
  }

  logger.debug(
    { jti: payload.jti, sub: payload.sub, aud },
    'Encounter JWT verified',
  );

  return {
    jti: payload.jti,
    sub: payload.sub,
    aud,
    iat: payload.iat ?? Math.floor(Date.now() / 1000),
    lat: payload['lat'] as number | undefined,
    lng: payload['lng'] as number | undefined,
  };
}
