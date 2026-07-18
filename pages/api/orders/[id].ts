import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { routerOptions } from '@/lib/api/router-config';
import { auth } from '@/middleware/auth';
import { orderService } from '@/services/order.service';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.use(auth).get(async (req, res) => {
  const includeAddress = req.query.include === 'address';
  res.status(200).json({ success: true, data: await orderService.detail(req.user!.sub, req.user!.role, String(req.query.id), includeAddress) });
});
export default router.handler(routerOptions);
