import type { NextApiHandler } from 'next';
import { env } from '@/lib/config/env';

const allowedDevOrigins = new Set([
  'http://localhost:8081',
  'http://127.0.0.1:8081',
]);

const configuredOrigins = new Set(
  (env.CORS_ALLOWED_ORIGINS ?? '').split(',').map((origin) => origin.trim()).filter(Boolean),
);

export function withCors(handler: NextApiHandler): NextApiHandler {
  return async (req, res) => {
    const origin = req.headers.origin;
    const originAllowed = origin && (
      configuredOrigins.has(origin) ||
      (env.NODE_ENV !== 'production' && allowedDevOrigins.has(origin))
    );

    if (originAllowed) {
      res.setHeader('Access-Control-Allow-Origin', origin);
      res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PATCH,OPTIONS');
      res.setHeader(
        'Access-Control-Allow-Headers',
        'Content-Type, Authorization, X-Bypass-Cache',
      );
      res.setHeader('Vary', 'Origin');
    }

    if (req.method === 'OPTIONS') {
      res.status(204).end();
      return;
    }

    await handler(req, res);
  };
}
