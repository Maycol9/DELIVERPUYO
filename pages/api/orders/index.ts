import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { routerOptions } from '@/lib/api/router-config';
import { auth } from '@/middleware/auth';
import { ApiError } from '@/errors/api-error';
import { createOrderSchema } from '@/validations/orders';
import { orderService } from '@/services/order.service';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.use(auth)
  .get(async (req, res) => {
    const limit = Math.min(50, Math.max(1, Number(req.query.limit ?? 20)));
    res.status(200).json({ success: true, data: await orderService.listOptimized(req.user!.sub, req.user!.role, limit) });
  })
  .post(async (req, res) => {
    const parsed = createOrderSchema.safeParse(req.body);
    if (!parsed.success) throw new ApiError(422, 'Datos del pedido inválidos', parsed.error.flatten().fieldErrors);
    res.status(201).json({ success: true, data: await orderService.create(req.user!.sub, parsed.data), message: 'Pedido creado; comprobante en procesamiento' });
  });
export default router.handler(routerOptions);
