import type { NextApiRequest, NextApiResponse } from 'next';
import type { NextHandler } from 'next-connect';
import { ApiError } from '@/errors/api-error';

export const requireRoles = (...roles: Array<'CLIENT' | 'ADMIN'>) =>
  async (req: NextApiRequest, _res: NextApiResponse, next: NextHandler): Promise<void> => {
    if (!req.user || !roles.includes(req.user.role)) throw new ApiError(403, 'No tiene permisos para esta operación');
    await next();
  };
