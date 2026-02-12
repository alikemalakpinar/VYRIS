import type pg from 'pg';
import { secureToken } from '../utils/hash.js';
import { validatePublicKeyPem, normalizePublicKeyPem } from '../security/pem-parse.js';
import { logger } from '../config/logger.js';
import * as errors from '../utils/errors.js';
import { env } from '../config/env.js';

const REFORGE_TTL_HOURS = 24;

export interface ReforgeRequest {
  id: string;
  membership_id: string;
  token: string;
  status: string;
  expires_at: string;
}

/**
 * Initiate a reforge (device transfer).
 *
 * Flow:
 *   1. Verify membership exists and caller owns it
 *   2. Verify the old device is currently active
 *   3. Validate new public key format
 *   4. Create a PENDING reforge request with a secure token
 *   5. (Stub) Send email with confirmation deep link
 */
export async function initiateReforge(
  client: pg.PoolClient,
  membershipId: string,
  userId: string,
  oldDeviceId: string,
  newDeviceId: string,
  newPublicKey: string,
): Promise<{ reforgeId: string; confirmUrl: string }> {
  // 1. Verify ownership
  const { rows: membership } = await client.query(
    'SELECT id, user_id FROM memberships WHERE id = $1 AND revoked = FALSE',
    [membershipId],
  );
  if (membership.length === 0 || membership[0]!.user_id !== userId) {
    throw errors.unauthorized('Membership not found or not owned by user');
  }

  // 2. Verify old device is active
  const { rows: oldDevice } = await client.query(
    `SELECT id FROM membership_devices
     WHERE membership_id = $1 AND device_id = $2 AND is_active = TRUE`,
    [membershipId, oldDeviceId],
  );
  if (oldDevice.length === 0) {
    throw errors.notFound('Active device not found for this membership');
  }

  // 3. Validate new key
  if (!validatePublicKeyPem(newPublicKey)) {
    throw errors.invalidReceipt('Invalid public key PEM format');
  }

  // 4. Create reforge request
  const token = secureToken(48);
  const expiresAt = new Date(Date.now() + REFORGE_TTL_HOURS * 3600 * 1000).toISOString();

  const { rows } = await client.query<ReforgeRequest>(
    `INSERT INTO reforge_requests (membership_id, old_device_id, new_device_id, new_public_key, token, expires_at)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [membershipId, oldDeviceId, newDeviceId, normalizePublicKeyPem(newPublicKey), token, expiresAt],
  );

  const reforge = rows[0]!;
  const confirmUrl = `${env.REFORGE_BASE_URL}/reforge/confirm?token=${token}`;

  // 5. Stub: send email
  logger.info(
    {
      reforgeId: reforge.id,
      membershipId,
      confirmUrl,
      expiresAt,
    },
    'Reforge initiated — email stub (not sent)',
  );

  return { reforgeId: reforge.id, confirmUrl };
}

/**
 * Confirm a reforge by token (from email deep link).
 *
 * Flow:
 *   1. Find PENDING reforge request by token
 *   2. Verify not expired
 *   3. Revoke old device key
 *   4. Register new device key
 *   5. Mark reforge as CONFIRMED
 */
export async function confirmReforge(
  client: pg.PoolClient,
  token: string,
): Promise<{ membershipId: string; newDeviceId: string }> {
  // 1. Find request
  const { rows } = await client.query<{
    id: string;
    membership_id: string;
    old_device_id: string;
    new_device_id: string;
    new_public_key: string;
    status: string;
    expires_at: string;
  }>(
    `SELECT * FROM reforge_requests WHERE token = $1 AND status = 'PENDING'`,
    [token],
  );

  if (rows.length === 0) {
    throw errors.notFound('Reforge request not found or already processed');
  }

  const req = rows[0]!;

  // 2. Check expiry
  if (new Date(req.expires_at) < new Date()) {
    await client.query(
      `UPDATE reforge_requests SET status = 'EXPIRED' WHERE id = $1`,
      [req.id],
    );
    throw errors.expired('Reforge request has expired');
  }

  // 3. Revoke old device
  await client.query(
    `UPDATE membership_devices
     SET is_active = FALSE, revoked_at = now()
     WHERE membership_id = $1 AND device_id = $2 AND is_active = TRUE`,
    [req.membership_id, req.old_device_id],
  );

  // 4. Register new device
  await client.query(
    `INSERT INTO membership_devices (membership_id, device_id, public_key)
     VALUES ($1, $2, $3)
     ON CONFLICT (membership_id, device_id)
     DO UPDATE SET public_key = $3, is_active = TRUE, revoked_at = NULL, registered_at = now()`,
    [req.membership_id, req.new_device_id, req.new_public_key],
  );

  // 5. Mark confirmed
  await client.query(
    `UPDATE reforge_requests SET status = 'CONFIRMED', confirmed_at = now() WHERE id = $1`,
    [req.id],
  );

  logger.info(
    {
      reforgeId: req.id,
      membershipId: req.membership_id,
      oldDevice: req.old_device_id,
      newDevice: req.new_device_id,
    },
    'Reforge confirmed',
  );

  return { membershipId: req.membership_id, newDeviceId: req.new_device_id };
}
