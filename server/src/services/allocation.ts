import type pg from 'pg';
import { logger } from '../config/logger.js';

export interface AllocationRow {
  id: string;
  tier: string;
  year: string;
  sequence_num: number;
  sort_order: number;
}

/**
 * Claim the next unclaimed allocation using SKIP LOCKED.
 *
 * This is the core scarcity mechanism:
 *   1. SELECT ... WHERE claimed = FALSE ORDER BY sort_order FOR UPDATE SKIP LOCKED LIMIT 1
 *   2. UPDATE claimed = TRUE, claimed_by, claimed_at
 *
 * SKIP LOCKED ensures concurrent mints don't deadlock — they each grab a different row.
 * sort_order randomization means the sequence_num assignment is unpredictable.
 *
 * Must be called within a transaction.
 */
export async function claimNextAllocation(
  client: pg.PoolClient,
  tier: string,
  year: string,
  userId: string,
): Promise<AllocationRow | null> {
  // Step 1: Lock an unclaimed row (skip any locked by concurrent transactions)
  const { rows } = await client.query<AllocationRow>(
    `SELECT id, tier, year, sequence_num, sort_order
     FROM allocation_pool
     WHERE tier = $1 AND year = $2 AND claimed = FALSE
     ORDER BY sort_order
     FOR UPDATE SKIP LOCKED
     LIMIT 1`,
    [tier, year],
  );

  if (rows.length === 0) {
    logger.warn({ tier, year }, 'No unclaimed allocations available');
    return null;
  }

  const allocation = rows[0]!;

  // Step 2: Mark as claimed
  await client.query(
    `UPDATE allocation_pool
     SET claimed = TRUE, claimed_by = $2, claimed_at = now()
     WHERE id = $1`,
    [allocation.id, userId],
  );

  logger.info(
    { allocationId: allocation.id, sequenceNum: allocation.sequence_num, userId },
    'Allocation claimed',
  );

  return allocation;
}
