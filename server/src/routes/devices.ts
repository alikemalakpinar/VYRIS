import type { FastifyInstance } from 'fastify';
import { withTransaction } from '../db/pool.js';
import { initiateReforge, confirmReforge } from '../services/reforge.js';
import * as errors from '../utils/errors.js';

interface ReforgeInitBody {
  membership_id: string;
  user_id: string;
  old_device_id: string;
  new_device_id: string;
  new_public_key: string;
}

interface ReforgeConfirmBody {
  token: string;
}

export async function deviceRoutes(app: FastifyInstance): Promise<void> {
  /**
   * POST /devices/reforge/init
   * Initiate a device transfer. Sends email confirmation link (stub).
   */
  app.post<{ Body: ReforgeInitBody }>(
    '/devices/reforge/init',
    async (request, reply) => {
      const { membership_id, user_id, old_device_id, new_device_id, new_public_key } =
        request.body;

      if (!membership_id || !user_id || !old_device_id || !new_device_id || !new_public_key) {
        throw errors.invalidReceipt(
          'Missing required fields: membership_id, user_id, old_device_id, new_device_id, new_public_key',
        );
      }

      const result = await withTransaction((client) =>
        initiateReforge(
          client,
          membership_id,
          user_id,
          old_device_id,
          new_device_id,
          new_public_key,
        ),
      );

      return reply.status(202).send({
        status: 'PENDING',
        reforge_id: result.reforgeId,
        confirm_url: result.confirmUrl,
        message: 'Confirmation email sent (stub). Use confirm_url to complete reforge.',
      });
    },
  );

  /**
   * POST /devices/reforge/confirm
   * Confirm a reforge via token from email deep link.
   */
  app.post<{ Body: ReforgeConfirmBody }>(
    '/devices/reforge/confirm',
    async (request, reply) => {
      const { token } = request.body;

      if (!token) {
        throw errors.invalidReceipt('Missing reforge token');
      }

      const result = await withTransaction((client) =>
        confirmReforge(client, token),
      );

      return reply.status(200).send({
        status: 'CONFIRMED',
        membership_id: result.membershipId,
        new_device_id: result.newDeviceId,
      });
    },
  );
}
