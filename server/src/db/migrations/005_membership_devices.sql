-- 005_membership_devices.sql
-- Device key registration for membership holders.
-- Supports reforge (device transfer) via email deep link confirmation.

CREATE TABLE IF NOT EXISTS membership_devices (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  membership_id   UUID NOT NULL REFERENCES memberships(id),
  device_id       TEXT NOT NULL,                 -- vendor identifier or key fingerprint
  public_key      TEXT NOT NULL,                 -- PEM-encoded EC P-256 public key
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  registered_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  revoked_at      TIMESTAMPTZ,

  UNIQUE (membership_id, device_id)
);

CREATE INDEX idx_membership_devices_active
  ON membership_devices (membership_id)
  WHERE is_active = TRUE;

-- Reforge requests (pending device transfers)
CREATE TABLE IF NOT EXISTS reforge_requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  membership_id   UUID NOT NULL REFERENCES memberships(id),
  old_device_id   TEXT NOT NULL,
  new_device_id   TEXT NOT NULL,
  new_public_key  TEXT NOT NULL,
  token           TEXT NOT NULL UNIQUE,          -- secure random token for email confirmation
  status          TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'EXPIRED')),
  expires_at      TIMESTAMPTZ NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  confirmed_at    TIMESTAMPTZ
);

CREATE INDEX idx_reforge_token ON reforge_requests (token) WHERE status = 'PENDING';
