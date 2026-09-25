import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { z } from 'zod';
import { routerOptions } from '@/lib/api/router-config';
import { auth } from '@/middleware/auth';
import { requireRoles } from '@/middleware/roles';
import { ApiError } from '@/errors/api-error';
import { productUpdateSchema } from '@/validations/products';
import { productService } from '@/services/product.service';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.use(auth).patch(requireRoles('ADMIN'), async (req, res) => {
  const id = z.string().uuid().safeParse(String(req.query.id));
  if (!id.success) throw new ApiError(422, 'Identificador de producto inválido', id.error.flatten().formErrors);
  const parsed = productUpdateSchema.safeParse(req.body);
  if (!parsed.success) throw new ApiError(422, 'Datos de actualización inválidos', parsed.error.flatten().fieldErrors);
  res.status(200).json({ success: true, data: await productService.update(id.data, parsed.data) });
});
export default router.handler(routerOptions);
