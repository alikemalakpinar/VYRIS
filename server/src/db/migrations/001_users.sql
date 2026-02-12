-- 001_users.sql
-- Core user identity table. One row per Apple ID / device owner.

CREATE TABLE IF NOT EXISTS users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  apple_user_id TEXT UNIQUE,                     -- from Sign in with Apple (nullable until linked)
  email         TEXT,                             -- from Apple ID or manual entry
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_apple_user_id ON users (apple_user_id) WHERE apple_user_id IS NOT NULL;
CREATE INDEX idx_users_email ON users (email) WHERE email IS NOT NULL;
