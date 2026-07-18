import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { z } from 'zod';
import { routerOptions } from '@/lib/api/router-config';
import { auth } from '@/middleware/auth';
import { ApiError } from '@/errors/api-error';
import { orderService } from '@/services/order.service';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.use(auth).get(async (req, res) => {
  const includeAddress = req.query.include === 'address';
  const id = z.string().uuid().safeParse(String(req.query.id));
  if (!id.success) throw new ApiError(422, 'Identificador de pedido inválido', id.error.flatten().formErrors);
  res.status(200).json({ success: true, data: await orderService.detail(req.user!.sub, req.user!.role, id.data, includeAddress) });
});
export default router.handler(routerOptions);
