import pg from 'pg';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';

/**
 * Seed the allocation_pool with `capacity` rows for a given tier/year.
 * sort_order is randomized via Fisher-Yates so that SKIP LOCKED claim
 * order is unpredictable.
 */
async function seed() {
  const tier = env.DROP_TIER;
  const year = env.DROP_YEAR;
  const capacity = env.DROP_CAPACITY;

  logger.info({ tier, year, capacity }, 'Seeding allocation pool');

  const client = new pg.Client({ connectionString: env.DATABASE_URL });
  await client.connect();

  try {
    // Check existing count
    const { rows } = await client.query(
      'SELECT COUNT(*)::int AS cnt FROM allocation_pool WHERE tier = $1 AND year = $2',
      [tier, year],
    );
    const existing = rows[0]?.cnt ?? 0;

    if (existing >= capacity) {
      logger.info({ existing, capacity }, 'Pool already seeded, skipping');
      return;
    }

    if (existing > 0) {
      logger.warn(
        { existing, capacity },
        'Partial seed detected. Deleting and re-seeding.',
      );
      await client.query(
        'DELETE FROM allocation_pool WHERE tier = $1 AND year = $2 AND claimed = FALSE',
        [tier, year],
      );
    }

    // Generate randomized sort_order via Fisher-Yates
    const sortOrders = Array.from({ length: capacity }, (_, i) => i + 1);
    for (let i = sortOrders.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [sortOrders[i], sortOrders[j]] = [sortOrders[j]!, sortOrders[i]!];
    }

    // Batch insert
    await client.query('BEGIN');
    const batchSize = 100;
    for (let i = 0; i < capacity; i += batchSize) {
      const batch = sortOrders.slice(i, i + batchSize);
      const values: string[] = [];
      const params: (string | number)[] = [];
      let paramIdx = 1;

      for (let j = 0; j < batch.length; j++) {
        const seqNum = i + j + 1;
        values.push(
          `($${paramIdx}, $${paramIdx + 1}, $${paramIdx + 2}, $${paramIdx + 3})`,
        );
        params.push(tier, year, seqNum, batch[j]!);
        paramIdx += 4;
      }

      await client.query(
        `INSERT INTO allocation_pool (tier, year, sequence_num, sort_order) VALUES ${values.join(', ')}
         ON CONFLICT (tier, year, sequence_num) DO NOTHING`,
        params,
      );
    }
    await client.query('COMMIT');
    logger.info({ tier, year, capacity }, 'Allocation pool seeded');
  } finally {
    await client.end();
  }
}

seed().catch((err) => {
  logger.fatal({ err }, 'Seed runner failed');
  process.exit(1);
});
