import type pg from 'pg';
import { v4 as uuidv4 } from 'uuid';
import { logger } from '../config/logger.js';

export interface MembershipRow {
  id: string;
  user_id: string;
  allocation_id: string;
  tier: string;
  year: string;
  sequence_num: number;
  pass_serial: string;
  revoked: boolean;
  created_at: string;
}

/**
 * Create a membership from a claimed allocation.
 * Must be called within the same transaction as claimNextAllocation.
 */
export async function createMembership(
  client: pg.PoolClient,
  userId: string,
  allocationId: string,
  tier: string,
  year: string,
  sequenceNum: number,
): Promise<MembershipRow> {
  const passSerial = `vyris-${tier}-${year}-${uuidv4()}`;

  const { rows } = await client.query<MembershipRow>(
    `INSERT INTO memberships (user_id, allocation_id, tier, year, sequence_num, pass_serial)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [userId, allocationId, tier, year, sequenceNum, passSerial],
  );

  const membership = rows[0]!;
  logger.info(
    {
      membershipId: membership.id,
      userId,
      tier,
      year,
      sequenceNum,
      passSerial,
    },
    'Membership created',
  );

  return membership;
}

/** Fetch a membership by ID. */
export async function getMembership(
  client: pg.PoolClient,
  membershipId: string,
): Promise<MembershipRow | null> {
  const { rows } = await client.query<MembershipRow>(
    'SELECT * FROM memberships WHERE id = $1',
    [membershipId],
  );
  return rows[0] ?? null;
}

/** Fetch a membership by user ID (latest). */
export async function getMembershipByUser(
  client: pg.PoolClient,
  userId: string,
  tier: string,
  year: string,
): Promise<MembershipRow | null> {
  const { rows } = await client.query<MembershipRow>(
    `SELECT * FROM memberships
     WHERE user_id = $1 AND tier = $2 AND year = $3 AND revoked = FALSE
     ORDER BY created_at DESC LIMIT 1`,
    [userId, tier, year],
  );
  return rows[0] ?? null;
}
