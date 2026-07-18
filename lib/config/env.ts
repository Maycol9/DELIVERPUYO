import { z } from 'zod';

const booleanFromString = z.preprocess((value) => {
  if (typeof value === 'string') return value.toLowerCase() === 'true';
  return value;
}, z.boolean());

const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  DATABASE_URL: z.string().min(1),
  REDIS_URL: z.string().url(),
  JWT_ACCESS_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),
  ACCESS_TOKEN_MINUTES: z.coerce.number().int().positive().default(15),
  REFRESH_TOKEN_DAYS: z.coerce.number().int().positive().default(7),
  PRODUCT_CACHE_TTL_SECONDS: z.coerce.number().int().positive().default(120),
  QUEUE_ENABLED: booleanFromString.default(true),
  ENABLE_BENCHMARK_ENDPOINTS: booleanFromString.default(false),
});

export const env = schema.parse(process.env);
