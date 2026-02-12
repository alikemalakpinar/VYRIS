import type { FastifyInstance } from 'fastify';
import { withTransaction } from '../db/pool.js';
import { verifyAndRecordEncounter } from '../services/encounter.js';
import * as errors from '../utils/errors.js';

interface VerifyEncounterBody {
  token: string;
}

export async function encounterRoutes(app: FastifyInstance): Promise<void> {
  app.post<{ Body: VerifyEncounterBody }>(
    '/encounters/verify',
    async (request, reply) => {
      const { token } = request.body;

      if (!token) {
        throw errors.invalidReceipt('Missing encounter token');
      }

      const encounter = await withTransaction((client) =>
        verifyAndRecordEncounter(client, token),
      );

      return reply.status(201).send({
        status: 'VERIFIED',
        encounter: {
          id: encounter.id,
          initiator_id: encounter.initiator_id,
          receiver_id: encounter.receiver_id,
          encountered_at: encounter.encountered_at,
          verified_at: encounter.verified_at,
        },
      });
    },
  );
}
