-- 002_receipt_ledger.sql
-- Idempotency ledger for App Store receipt processing.
-- Every receipt is recorded exactly once. Status tracks progress.
-- On retry: PENDING = resume, FULFILLED = return existing membership.

CREATE TYPE receipt_status AS ENUM ('PENDING', 'FULFILLED', 'FAILED');

CREATE TABLE IF NOT EXISTS receipt_ledger (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  receipt_hash    TEXT NOT NULL UNIQUE,           -- SHA-256 of the receipt data (dedup key)
  original_tx_id  TEXT,                           -- Apple original_transaction_id
  user_id         UUID REFERENCES users(id),
  status          receipt_status NOT NULL DEFAULT 'PENDING',
  membership_id   UUID,                           -- set when FULFILLED (FK added after memberships table)
  error_detail    TEXT,                            -- set when FAILED
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_receipt_ledger_status ON receipt_ledger (status);
CREATE INDEX idx_receipt_ledger_user ON receipt_ledger (user_id);
CREATE INDEX idx_receipt_ledger_original_tx ON receipt_ledger (original_tx_id) WHERE original_tx_id IS NOT NULL;
