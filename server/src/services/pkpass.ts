import { logger } from '../config/logger.js';
import type { MembershipRow } from './membership.js';

/**
 * PKPass generation stub.
 *
 * In production this will:
 *   1. Build a pass.json with membership data
 *   2. Add icon/logo/strip images
 *   3. Create manifest.json with SHA-1 hashes
 *   4. Sign with Apple WWDR + pass certificate
 *   5. Bundle into .pkpass (ZIP)
 *
 * For now, returns a placeholder binary and the correct Content-Type.
 */
export interface PkPassResult {
  buffer: Buffer;
  contentType: string;
  filename: string;
}

export async function generatePkPass(
  membership: MembershipRow,
): Promise<PkPassResult> {
  logger.info(
    {
      membershipId: membership.id,
      passSerial: membership.pass_serial,
      tier: membership.tier,
      sequenceNum: membership.sequence_num,
    },
    'Generating pkpass (stub)',
  );

  // Stub: create a minimal JSON payload as placeholder
  const passJson = {
    formatVersion: 1,
    passTypeIdentifier: 'pass.app.vyris.membership',
    serialNumber: membership.pass_serial,
    teamIdentifier: 'VYRIS',
    organizationName: 'VYRIS',
    description: `VYRIS ${membership.tier} #${membership.sequence_num}`,
    generic: {
      primaryFields: [
        {
          key: 'member',
          label: 'MEMBER',
          value: `#${membership.sequence_num}`,
        },
      ],
      secondaryFields: [
        {
          key: 'tier',
          label: 'TIER',
          value: membership.tier.toUpperCase(),
        },
        {
          key: 'year',
          label: 'YEAR',
          value: membership.year,
        },
      ],
    },
  };

  const buffer = Buffer.from(JSON.stringify(passJson, null, 2), 'utf-8');

  return {
    buffer,
    contentType: 'application/vnd.apple.pkpass',
    filename: `vyris-${membership.tier}-${membership.sequence_num}.pkpass`,
  };
}
