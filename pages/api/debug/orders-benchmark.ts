import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { routerOptions } from '@/lib/api/router-config';
import { auth } from '@/middleware/auth';
import { requireRoles } from '@/middleware/roles';
import { ApiError } from '@/errors/api-error';
import { env } from '@/lib/config/env';
import { orderService } from '@/services/order.service';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.use(auth).get(requireRoles('ADMIN'), async (req, res) => {
  if (!env.ENABLE_BENCHMARK_ENDPOINTS) throw new ApiError(404, 'Endpoint no disponible');
  const limit = Math.min(50, Math.max(1, Number(req.query.limit ?? 20)));
  const mode = req.query.mode === 'nplus1' ? 'nplus1' : 'optimized';
  const result = mode === 'nplus1' ? await orderService.benchmarkNPlusOne(limit) : await orderService.benchmarkOptimized(limit);
  res.status(200).json({ success: true, data: result });
});
export default router.handler(routerOptions);
