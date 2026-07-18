import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { routerOptions } from '@/lib/api/router-config';
import { auth } from '@/middleware/auth';
import { requireRoles } from '@/middleware/roles';
import { ApiError } from '@/errors/api-error';
import { productCreateSchema, productQuerySchema } from '@/validations/products';
import { productService } from '@/services/product.service';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.get(async (req, res) => {
  const parsed = productQuerySchema.safeParse(req.query);
  if (!parsed.success) throw new ApiError(422, 'Parámetros de consulta inválidos', parsed.error.flatten().fieldErrors);
  const result = await productService.list(parsed.data, req.headers['x-bypass-cache'] === '1');
  res.setHeader('X-Cache', result.cache);
  res.status(200).json(result);
});
router.use(auth).post(requireRoles('ADMIN'), async (req, res) => {
  const parsed = productCreateSchema.safeParse(req.body);
  if (!parsed.success) throw new ApiError(422, 'Datos del producto inválidos', parsed.error.flatten().fieldErrors);
  res.status(201).json({ success: true, data: await productService.create(parsed.data) });
});
export default router.handler(routerOptions);
