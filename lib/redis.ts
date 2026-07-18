import IORedis from 'ioredis';
import { env } from '@/lib/config/env';

const globalForRedis = globalThis as typeof globalThis & { redis?: IORedis };

export const redis = globalForRedis.redis ?? new IORedis(env.REDIS_URL, {
  maxRetriesPerRequest: null,
  enableReadyCheck: true,
  lazyConnect: true,
});

if (process.env.NODE_ENV !== 'production') globalForRedis.redis = redis;

export async function ensureRedis(): Promise<void> {
  if (redis.status === 'wait') await redis.connect();
}

export async function invalidatePattern(pattern: string): Promise<number> {
  await ensureRedis();
  let cursor = '0';
  let removed = 0;
  do {
    const [nextCursor, keys] = await redis.scan(cursor, 'MATCH', pattern, 'COUNT', 100);
    cursor = nextCursor;
    if (keys.length > 0) removed += await redis.del(...keys);
  } while (cursor !== '0');
  return removed;
}
