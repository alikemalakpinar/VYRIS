import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const migrationsDir = path.join(__dirname, 'migrations');

async function migrate() {
  const client = new pg.Client({ connectionString: env.DATABASE_URL });
  await client.connect();

  try {
    // Create migrations tracking table
    await client.query(`
      CREATE TABLE IF NOT EXISTS _migrations (
        name TEXT PRIMARY KEY,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
      )
    `);

    const { rows: applied } = await client.query(
      'SELECT name FROM _migrations ORDER BY name',
    );
    const appliedSet = new Set(applied.map((r) => r.name));

    const files = fs
      .readdirSync(migrationsDir)
      .filter((f) => f.endsWith('.sql'))
      .sort();

    for (const file of files) {
      if (appliedSet.has(file)) {
        logger.debug({ file }, 'Migration already applied, skipping');
        continue;
      }

      const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf-8');
      logger.info({ file }, 'Applying migration');

      await client.query('BEGIN');
      try {
        await client.query(sql);
        await client.query('INSERT INTO _migrations (name) VALUES ($1)', [
          file,
        ]);
        await client.query('COMMIT');
        logger.info({ file }, 'Migration applied successfully');
      } catch (err) {
        await client.query('ROLLBACK');
        logger.error({ file, err }, 'Migration failed');
        throw err;
      }
    }

    logger.info('All migrations applied');
  } finally {
    await client.end();
  }
}

migrate().catch((err) => {
  logger.fatal({ err }, 'Migration runner failed');
  process.exit(1);
});
