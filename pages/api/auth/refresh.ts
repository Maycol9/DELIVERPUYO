import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { routerOptions } from '@/lib/api/router-config';
import { refreshSchema } from '@/validations/auth';
import { ApiError } from '@/errors/api-error';
import { authService } from '@/services/auth.service';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.post(async (req, res) => {
  const parsed = refreshSchema.safeParse(req.body);
  if (!parsed.success) throw new ApiError(422, 'Refresh token requerido');
  res.status(200).json({ success: true, data: await authService.refresh(parsed.data.refreshToken) });
});
export default router.handler(routerOptions);
