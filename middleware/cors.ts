import type { NextApiRequest, NextApiResponse } from 'next';
import type { NextHandler } from 'next-connect';

const allowedDevOrigins = new Set([
  'http://localhost:8081',
  'http://127.0.0.1:8081',
]);

export async function devCors(
  req: NextApiRequest,
  res: NextApiResponse,
  next: NextHandler,
): Promise<void> {
  const origin = req.headers.origin;

  if (origin && allowedDevOrigins.has(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
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

  await next();
}
