import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { redis } from './client.js';
import { logger } from '../config/logger.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const luaScript = fs.readFileSync(path.join(__dirname, 'bouncer.lua'), 'utf-8');

function slotKey(tier: string, year: string): string {
  return `drop:${tier}:${year}:slots`;
}

/** Initialize the bouncer with a given capacity. Idempotent (NX). */
export async function initBouncer(
  tier: string,
  year: string,
  capacity: number,
): Promise<void> {
  const key = slotKey(tier, year);
  const set = await redis.set(key, capacity, 'NX');
  if (set) {
    logger.info({ tier, year, capacity }, 'Bouncer initialized');
  } else {
    logger.debug({ tier, year }, 'Bouncer already initialized, skipping');
  }
}

/**
 * Try to acquire a slot atomically.
 * Returns true if a slot was acquired, false if sold out.
 */
export async function acquireSlot(
  tier: string,
  year: string,
): Promise<boolean> {
  const result = await redis.eval(luaScript, 1, slotKey(tier, year));
  return result === 1;
}

/**
 * Compensate: return a slot after a failed transaction.
 * This is the safety valve — if Postgres TX fails after Redis decrement,
 * we INCR to restore the slot.
 */
export async function compensateSlot(
  tier: string,
  year: string,
): Promise<void> {
  const key = slotKey(tier, year);
  await redis.incr(key);
  logger.warn({ tier, year }, 'Slot compensated (returned to pool)');
}

/** Get current remaining slots (read-only, for monitoring). */
export async function remainingSlots(
  tier: string,
  year: string,
): Promise<number> {
  const val = await redis.get(slotKey(tier, year));
  return val ? parseInt(val, 10) : 0;
}
