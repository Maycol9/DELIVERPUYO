import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { routerOptions } from '@/lib/api/router-config';
import { registerSchema } from '@/validations/auth';
import { ApiError } from '@/errors/api-error';
import { authService } from '@/services/auth.service';
import { devCors } from '@/middleware/cors';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.use(devCors);
router.post(async (req, res) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) throw new ApiError(422, 'Datos de registro inválidos', parsed.error.flatten().fieldErrors);
  res.status(201).json({ success: true, data: await authService.register(parsed.data) });
});

const handler = router.handler(routerOptions);

export default function registerHandler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }
  return handler(req, res);
}
