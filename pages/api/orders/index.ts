import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { routerOptions } from '@/lib/api/router-config';
import { auth } from '@/middleware/auth';
import { ApiError } from '@/errors/api-error';
import { createOrderSchema } from '@/validations/orders';
import { orderService } from '@/services/order.service';
import { pagination } from '@/helper/pagination';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.use(auth)
  .get(async (req, res) => {
    const p = pagination(req.query.page, req.query.limit);
    const [data, total] = await orderService.listOptimized(req.user!.sub, req.user!.role, p.page, p.limit);
    res.status(200).json({ success: true, data, pagination: p.meta(total) });
  })
  .post(async (req, res) => {
    const parsed = createOrderSchema.safeParse(req.body);
    if (!parsed.success) throw new ApiError(422, 'Datos del pedido inválidos', parsed.error.flatten().fieldErrors);
    res.status(201).json({ success: true, data: await orderService.create(req.user!.sub, parsed.data), message: 'Pedido creado; comprobante en procesamiento' });
  });
export default router.handler(routerOptions);
