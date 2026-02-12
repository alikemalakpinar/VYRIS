-- 003_allocation_pool.sql
-- Pre-seeded pool of numbered allocations for a drop.
-- Each row = one mintable membership slot.
-- sort_order is randomized at seed time so sequential claim (SKIP LOCKED)
-- produces a shuffled allocation sequence.

CREATE TABLE IF NOT EXISTS allocation_pool (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tier          TEXT NOT NULL,                   -- e.g. 'genesis'
  year          TEXT NOT NULL,                   -- e.g. '2025'
  sequence_num  INT NOT NULL,                    -- 1..N (the display number on the card)
  sort_order    INT NOT NULL,                    -- randomized; drives claim order
  claimed       BOOLEAN NOT NULL DEFAULT FALSE,
  claimed_by    UUID REFERENCES users(id),
  claimed_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE (tier, year, sequence_num)
);

-- Critical: the claim query orders by sort_order and uses SKIP LOCKED.
-- This index must exist for performance.
CREATE INDEX idx_allocation_pool_claim
  ON allocation_pool (tier, year, sort_order)
  WHERE claimed = FALSE;
