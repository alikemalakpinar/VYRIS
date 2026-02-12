/**
 * Utilities for parsing and validating PEM-encoded public keys
 * used in device registration.
 */

const PEM_HEADER = '-----BEGIN PUBLIC KEY-----';
const PEM_FOOTER = '-----END PUBLIC KEY-----';

export function validatePublicKeyPem(pem: string): boolean {
  const trimmed = pem.trim();
  if (!trimmed.startsWith(PEM_HEADER) || !trimmed.endsWith(PEM_FOOTER)) {
    return false;
  }

  // Extract base64 body
  const body = trimmed
    .replace(PEM_HEADER, '')
    .replace(PEM_FOOTER, '')
    .replace(/\s/g, '');

  // EC P-256 public key DER is 91 bytes → ~124 base64 chars
  // Allow some variance for different encodings
  if (body.length < 80 || body.length > 200) {
    return false;
  }

  // Validate base64
  try {
    const buf = Buffer.from(body, 'base64');
    return buf.length > 0;
  } catch {
    return false;
  }
}

export function normalizePublicKeyPem(pem: string): string {
  const trimmed = pem.trim();
  const body = trimmed
    .replace(PEM_HEADER, '')
    .replace(PEM_FOOTER, '')
    .replace(/\s/g, '');

  // Re-wrap at 64 chars per line
  const lines: string[] = [];
  for (let i = 0; i < body.length; i += 64) {
    lines.push(body.substring(i, i + 64));
  }

  return `${PEM_HEADER}\n${lines.join('\n')}\n${PEM_FOOTER}`;
}
