-- 006_encounters.sql
-- Server-authoritative encounter log.
-- When two members tap/scan, the client submits a signed JWT.
-- Server verifies and records the encounter.

CREATE TABLE IF NOT EXISTS encounters (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  initiator_id      UUID NOT NULL REFERENCES memberships(id),
  receiver_id       UUID NOT NULL REFERENCES memberships(id),
  encounter_token   TEXT NOT NULL UNIQUE,        -- the JWT jti (prevents replay)
  latitude          DOUBLE PRECISION,
  longitude         DOUBLE PRECISION,
  encountered_at    TIMESTAMPTZ NOT NULL,        -- from JWT iat
  verified_at       TIMESTAMPTZ NOT NULL DEFAULT now(),

  CHECK (initiator_id <> receiver_id)
);

CREATE INDEX idx_encounters_initiator ON encounters (initiator_id);
CREATE INDEX idx_encounters_receiver ON encounters (receiver_id);
CREATE INDEX idx_encounters_token ON encounters (encounter_token);
CREATE INDEX idx_encounters_time ON encounters (encountered_at);
