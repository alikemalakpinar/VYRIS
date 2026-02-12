import crypto from 'node:crypto';

/** SHA-256 hash of arbitrary data, returned as hex string. */
export function sha256(data: string | Buffer): string {
  return crypto.createHash('sha256').update(data).digest('hex');
}

/** Generate a cryptographically secure random token (URL-safe base64). */
export function secureToken(bytes: number = 32): string {
  return crypto.randomBytes(bytes).toString('base64url');
}
