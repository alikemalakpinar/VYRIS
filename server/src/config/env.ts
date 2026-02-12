import 'dotenv/config';

function required(key: string): string {
  const v = process.env[key];
  if (!v) throw new Error(`Missing required env var: ${key}`);
  return v;
}

function optional(key: string, fallback: string): string {
  return process.env[key] ?? fallback;
}

export const env = {
  NODE_ENV: optional('NODE_ENV', 'development'),
  PORT: parseInt(optional('PORT', '3000'), 10),
  HOST: optional('HOST', '0.0.0.0'),

  // Postgres
  DATABASE_URL: required('DATABASE_URL'),

  // Redis
  REDIS_URL: optional('REDIS_URL', 'redis://127.0.0.1:6379'),

  // JWT / Encounter verification
  ENCOUNTER_JWT_PUBLIC_KEY: required('ENCOUNTER_JWT_PUBLIC_KEY'),

  // PKPass signing (stubs for now)
  PKPASS_CERTIFICATE: optional('PKPASS_CERTIFICATE', ''),
  PKPASS_KEY: optional('PKPASS_KEY', ''),
  PKPASS_PASSPHRASE: optional('PKPASS_PASSPHRASE', ''),

  // Reforge email (stub)
  REFORGE_FROM_EMAIL: optional('REFORGE_FROM_EMAIL', 'noreply@vyris.app'),
  REFORGE_BASE_URL: optional('REFORGE_BASE_URL', 'https://vyris.app'),

  // Apple receipt verification
  APPLE_SHARED_SECRET: optional('APPLE_SHARED_SECRET', ''),

  // Drop config
  DROP_TIER: optional('DROP_TIER', 'genesis'),
  DROP_YEAR: optional('DROP_YEAR', '2025'),
  DROP_CAPACITY: parseInt(optional('DROP_CAPACITY', '999'), 10),
} as const;
