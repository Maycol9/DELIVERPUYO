import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { routerOptions } from '@/lib/api/router-config';
import { registerSchema } from '@/validations/auth';
import { ApiError } from '@/errors/api-error';
import { authService } from '@/services/auth.service';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.post(async (req, res) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) throw new ApiError(422, 'Datos de registro inválidos', parsed.error.flatten().fieldErrors);
  res.status(201).json({ success: true, data: await authService.register(parsed.data) });
});
export default router.handler(routerOptions);
