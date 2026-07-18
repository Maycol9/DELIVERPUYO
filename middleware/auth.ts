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
    await next();
  } catch {
    throw new ApiError(401, 'Token de acceso inválido o expirado');
  }
}
