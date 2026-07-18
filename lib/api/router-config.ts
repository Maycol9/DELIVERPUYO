import type { NextApiRequest, NextApiResponse } from 'next';
import { ApiError } from '@/errors/api-error';

export const routerOptions = {
  onError(error: unknown, _req: NextApiRequest, res: NextApiResponse) {
    if (error instanceof ApiError) {
      res.status(error.status).json({ success: false, message: error.message, errors: error.details ?? [] });
      return;
    }
    console.error(error);
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  },
  onNoMatch(_req: NextApiRequest, res: NextApiResponse) {
    res.status(405).json({ success: false, message: 'Método HTTP no permitido' });
  },
};
