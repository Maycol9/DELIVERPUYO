import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { routerOptions } from '@/lib/api/router-config';
import { loginSchema } from '@/validations/auth';
import { ApiError } from '@/errors/api-error';
import { authService } from '@/services/auth.service';
import { devCors } from '@/middleware/cors';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.use(devCors);
router.post(async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) throw new ApiError(422, 'Datos de inicio de sesión inválidos', parsed.error.flatten().fieldErrors);
  res.status(200).json({ success: true, data: await authService.login(parsed.data.email, parsed.data.password) });
});

const handler = router.handler(routerOptions);

export default function loginHandler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }
  return handler(req, res);
}
