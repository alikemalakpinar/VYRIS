import IORedis from 'ioredis';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';

export const redis = new IORedis.default(env.REDIS_URL, {
  maxRetriesPerRequest: 3,
  retryStrategy(times: number) {
    const delay = Math.min(times * 200, 2000);
    return delay;
  },
  enableReadyCheck: true,
  lazyConnect: false,
});

redis.on('error', (err: Error) => {
  logger.error({ err }, 'Redis connection error');
});

redis.on('connect', () => {
  logger.info('Redis connected');
});
