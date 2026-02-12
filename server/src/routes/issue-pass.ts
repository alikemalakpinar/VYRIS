import type { FastifyInstance } from 'fastify';
import { withClient } from '../db/pool.js';
import { getMembership } from '../services/membership.js';
import { generatePkPass } from '../services/pkpass.js';
import * as errors from '../utils/errors.js';

interface IssuePassBody {
  membership_id: string;
  user_id: string;
}

export async function issuePassRoutes(app: FastifyInstance): Promise<void> {
  app.post<{ Body: IssuePassBody }>('/issue-pass', async (request, reply) => {
    const { membership_id, user_id } = request.body;

    if (!membership_id || !user_id) {
      throw errors.invalidReceipt('Missing membership_id or user_id');
    }

    const membership = await withClient((client) =>
      getMembership(client, membership_id),
    );

    if (!membership) {
      throw errors.notFound('Membership not found');
    }

    if (membership.user_id !== user_id) {
      throw errors.unauthorized('Membership does not belong to this user');
    }

    if (membership.revoked) {
      throw errors.unauthorized('Membership has been revoked');
    }

    const pkpass = await generatePkPass(membership);

    return reply
      .status(200)
      .header('Content-Type', pkpass.contentType)
      .header(
        'Content-Disposition',
        `attachment; filename="${pkpass.filename}"`,
      )
      .send(pkpass.buffer);
  });
}
