-- 004_memberships.sql
-- The issued membership — the core asset.
-- One per allocation claim. Immutable once created (no edits, only revoke).

CREATE TABLE IF NOT EXISTS memberships (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id),
  allocation_id   UUID NOT NULL UNIQUE REFERENCES allocation_pool(id),
  tier            TEXT NOT NULL,
  year            TEXT NOT NULL,
  sequence_num    INT NOT NULL,                  -- denormalized from allocation for fast reads
  pass_serial     TEXT NOT NULL UNIQUE,          -- Apple Wallet serial number
  revoked         BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_memberships_user ON memberships (user_id);
CREATE INDEX idx_memberships_tier_year ON memberships (tier, year);

-- Now add FK from receipt_ledger to memberships
ALTER TABLE receipt_ledger
  ADD CONSTRAINT fk_receipt_membership
  FOREIGN KEY (membership_id) REFERENCES memberships(id);
