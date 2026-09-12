import type { NextApiRequest, NextApiResponse } from 'next';
import type { NextHandler } from 'next-connect';
import { ApiError } from '@/errors/api-error';
import { verifyAccessToken } from '@/lib/jwt';

export async function auth(req: NextApiRequest, _res: NextApiResponse, next: NextHandler): Promise<void> {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) throw new ApiError(401, 'Token de acceso no proporcionado');
  try {
    // Verificación local: no consulta la base de datos en cada solicitud protegida.
    req.user = await verifyAccessToken(header.slice(7));
  } catch {
    throw new ApiError(401, 'Token de acceso inválido o expirado');
  }
  // Route errors (422, 403, 409, 500) belong to the API error handler.
  // They must not trigger token renewal or invalidate a valid session.
  await next();
}
