import type { FastifyInstance } from 'fastify';
import { withClient, withTransaction } from '../db/pool.js';
import { acquireSlot, compensateSlot } from '../redis/bouncer.js';
import { upsertReceipt, fulfillReceipt, failReceipt } from '../services/receipt.js';
import { claimNextAllocation } from '../services/allocation.js';
import { createMembership, getMembership } from '../services/membership.js';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';
import * as errors from '../utils/errors.js';

interface MintBody {
  receipt_data: string;
  user_id: string;
  original_transaction_id?: string;
}

export async function mintRoutes(app: FastifyInstance): Promise<void> {
  app.post<{ Body: MintBody }>('/mint', async (request, reply) => {
    const { receipt_data, user_id, original_transaction_id } = request.body;

    if (!receipt_data || !user_id) {
      throw errors.invalidReceipt('Missing receipt_data or user_id');
    }

    const tier = env.DROP_TIER;
    const year = env.DROP_YEAR;

    // ─── Step 1: Check receipt ledger for idempotency ───────────────
    // Do this BEFORE the Redis bouncer to avoid wasting a slot on retries.
    const ledgerCheck = await withClient(async (client) => {
      return upsertReceipt(
        client,
        receipt_data,
        user_id,
        original_transaction_id ?? null,
      );
    });

    // If receipt already FULFILLED → return the existing membership
    if (!ledgerCheck.isNew && ledgerCheck.row.status === 'FULFILLED') {
      if (ledgerCheck.row.membership_id) {
        const membership = await withClient((client) =>
          getMembership(client, ledgerCheck.row.membership_id!),
        );
        if (membership) {
          logger.info(
            { receiptId: ledgerCheck.row.id, membershipId: membership.id },
            'Mint: returning existing fulfilled membership',
          );
          return reply.status(200).send({
            status: 'FULFILLED',
            membership: {
              id: membership.id,
              tier: membership.tier,
              year: membership.year,
              sequence_num: membership.sequence_num,
              pass_serial: membership.pass_serial,
            },
          });
        }
      }
      // Fulfilled but membership missing — data inconsistency, treat as retryable
      throw errors.retryable('Receipt fulfilled but membership not found');
    }

    // If FAILED previously, allow retry (re-use the ledger row)
    const receiptRow = ledgerCheck.row;

    // ─── Step 2: Redis bouncer — atomic slot check ──────────────────
    const slotAcquired = await acquireSlot(tier, year);
    if (!slotAcquired) {
      // No slots left — mark receipt FAILED
      await withClient(async (client) => {
        await failReceipt(client, receiptRow.id, 'SOLD_OUT');
      });
      throw errors.soldOut();
    }

    // ─── Step 3: Postgres transaction — claim + mint ────────────────
    // If this fails, we MUST compensate the Redis slot.
    try {
      const membership = await withTransaction(async (client) => {
        // Claim allocation (SKIP LOCKED)
        const allocation = await claimNextAllocation(client, tier, year, user_id);
        if (!allocation) {
          // Pool exhausted in Postgres (shouldn't happen if Redis is in sync)
          throw errors.soldOut();
        }

        // Create membership
        const m = await createMembership(
          client,
          user_id,
          allocation.id,
          tier,
          year,
          allocation.sequence_num,
        );

        // Fulfill receipt
        await fulfillReceipt(client, receiptRow.id, m.id);

        return m;
      });

      logger.info(
        {
          membershipId: membership.id,
          sequenceNum: membership.sequence_num,
          tier,
          year,
        },
        'Mint: success',
      );

      return reply.status(201).send({
        status: 'FULFILLED',
        membership: {
          id: membership.id,
          tier: membership.tier,
          year: membership.year,
          sequence_num: membership.sequence_num,
          pass_serial: membership.pass_serial,
        },
      });
    } catch (err) {
      // ─── Compensate Redis slot on Postgres failure ──────────────
      await compensateSlot(tier, year);

      // If SOLD_OUT from Postgres, propagate as-is
      if (err instanceof errors.AppError && err.code === 'SOLD_OUT') {
        await withClient(async (client) => {
          await failReceipt(client, receiptRow.id, 'SOLD_OUT');
        });
        throw err;
      }

      // Other Postgres errors → RETRYABLE
      logger.error({ err, receiptId: receiptRow.id }, 'Mint: transaction failed');
      throw errors.retryable('Mint transaction failed, slot returned — please retry');
    }
  });
}
