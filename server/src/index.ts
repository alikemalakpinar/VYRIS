import Fastify from 'fastify';
import fastifySensible from '@fastify/sensible';
import { env } from './config/env.js';
import { logger } from './config/logger.js';
import { pool } from './db/pool.js';
import { redis } from './redis/client.js';
import { initBouncer } from './redis/bouncer.js';
import { mintRoutes } from './routes/mint.js';
import { issuePassRoutes } from './routes/issue-pass.js';
import { encounterRoutes } from './routes/encounters.js';
import { deviceRoutes } from './routes/devices.js';
import { AppError } from './utils/errors.js';
import type { FastifyError } from 'fastify';

async function main() {
  const app = Fastify({
    logger: {
      level: env.NODE_ENV === 'production' ? 'info' : 'debug',
      serializers: {
        req(req) {
          return {
            method: req.method,
            url: req.url,
            hostname: req.hostname,
          };
        },
      },
      timestamp: () => `,"time":"${new Date().toISOString()}"`,
    },
    requestTimeout: 30_000,
    bodyLimit: 1_048_576, // 1 MB
  });

  // ─── Plugins ──────────────────────────────────────────────────
  await app.register(fastifySensible);

  // ─── Global error handler ─────────────────────────────────────
  app.setErrorHandler((error: FastifyError | AppError, _request, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send({
        error: error.code,
        message: error.message,
        retryable: error.retryable,
      });
    }

    // Fastify validation errors
    if ('validation' in error && error.validation) {
      return reply.status(422).send({
        error: 'VALIDATION_ERROR',
        message: error.message,
        retryable: false,
      });
    }

    // Unexpected errors
    logger.error({ err: error }, 'Unhandled error');
    return reply.status(500).send({
      error: 'RETRYABLE',
      message: 'Internal server error',
      retryable: true,
    });
  });

  // ─── Health check ─────────────────────────────────────────────
  app.get('/health', async (_request, reply) => {
    try {
      await pool.query('SELECT 1');
      await redis.ping();
      return reply.status(200).send({ status: 'ok' });
    } catch (err) {
      logger.error({ err }, 'Health check failed');
      return reply.status(503).send({ status: 'unhealthy' });
    }
  });

  // ─── Routes ───────────────────────────────────────────────────
  await app.register(mintRoutes);
  await app.register(issuePassRoutes);
  await app.register(encounterRoutes);
  await app.register(deviceRoutes);

  // ─── Initialize Redis bouncer ─────────────────────────────────
  await initBouncer(env.DROP_TIER, env.DROP_YEAR, env.DROP_CAPACITY);

  // ─── Start ────────────────────────────────────────────────────
  await app.listen({ port: env.PORT, host: env.HOST });
  logger.info(
    { port: env.PORT, host: env.HOST, tier: env.DROP_TIER, year: env.DROP_YEAR },
    'VYRIS server started',
  );

  // ─── Graceful shutdown ────────────────────────────────────────
  const shutdown = async (signal: string) => {
    logger.info({ signal }, 'Shutting down');
    await app.close();
    await pool.end();
    redis.disconnect();
    process.exit(0);
  };

  process.on('SIGTERM', () => void shutdown('SIGTERM'));
  process.on('SIGINT', () => void shutdown('SIGINT'));
}

main().catch((err) => {
  logger.fatal({ err }, 'Failed to start server');
  process.exit(1);
});
