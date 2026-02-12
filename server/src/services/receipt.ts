import type pg from 'pg';
import { sha256 } from '../utils/hash.js';
import { logger } from '../config/logger.js';

export interface ReceiptLedgerRow {
  id: string;
  receipt_hash: string;
  original_tx_id: string | null;
  user_id: string | null;
  status: 'PENDING' | 'FULFILLED' | 'FAILED';
  membership_id: string | null;
  error_detail: string | null;
}

/**
 * Upsert a receipt into the ledger with PENDING status.
 *
 * Idempotency contract:
 *   - If receipt_hash doesn't exist → INSERT PENDING, return { row, isNew: true }
 *   - If receipt_hash exists and PENDING → return { row, isNew: false } (caller resumes)
 *   - If receipt_hash exists and FULFILLED → return { row, isNew: false } (caller returns existing membership)
 *   - If receipt_hash exists and FAILED → return { row, isNew: false } (caller can retry)
 */
export async function upsertReceipt(
  client: pg.PoolClient,
  receiptData: string,
  userId: string,
  originalTxId: string | null,
): Promise<{ row: ReceiptLedgerRow; isNew: boolean }> {
  const receiptHash = sha256(receiptData);

  // Try insert first (happy path)
  const { rows: inserted } = await client.query<ReceiptLedgerRow>(
    `INSERT INTO receipt_ledger (receipt_hash, original_tx_id, user_id, status)
     VALUES ($1, $2, $3, 'PENDING')
     ON CONFLICT (receipt_hash) DO NOTHING
     RETURNING *`,
    [receiptHash, originalTxId, userId],
  );

  if (inserted.length > 0) {
    logger.info({ receiptHash, userId }, 'Receipt ledger: new PENDING entry');
    return { row: inserted[0]!, isNew: true };
  }

  // Conflict: receipt already exists. Fetch it.
  const { rows: existing } = await client.query<ReceiptLedgerRow>(
    'SELECT * FROM receipt_ledger WHERE receipt_hash = $1',
    [receiptHash],
  );

  if (existing.length === 0) {
    // Should not happen — race condition between insert and select
    throw new Error('Receipt ledger race: insert conflicted but row not found');
  }

  logger.info(
    { receiptHash, status: existing[0]!.status },
    'Receipt ledger: existing entry found',
  );
  return { row: existing[0]!, isNew: false };
}

/** Mark a receipt as FULFILLED with the membership ID. */
export async function fulfillReceipt(
  client: pg.PoolClient,
  receiptId: string,
  membershipId: string,
): Promise<void> {
  await client.query(
    `UPDATE receipt_ledger
     SET status = 'FULFILLED', membership_id = $2, updated_at = now()
     WHERE id = $1 AND status = 'PENDING'`,
    [receiptId, membershipId],
  );
  logger.info({ receiptId, membershipId }, 'Receipt fulfilled');
}

/** Mark a receipt as FAILED with error detail. */
export async function failReceipt(
  client: pg.PoolClient,
  receiptId: string,
  errorDetail: string,
): Promise<void> {
  await client.query(
    `UPDATE receipt_ledger
     SET status = 'FAILED', error_detail = $2, updated_at = now()
     WHERE id = $1`,
    [receiptId, errorDetail],
  );
  logger.warn({ receiptId, errorDetail }, 'Receipt failed');
}
