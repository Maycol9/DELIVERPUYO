import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { prisma } from '@/database/client';
import { ApiError } from '@/errors/api-error';
import { routerOptions } from '@/lib/api/router-config';
import { auth } from '@/middleware/auth';
import { devCors } from '@/middleware/cors';
import { requireRoles } from '@/middleware/roles';
import { categoryCreateSchema } from '@/validations/categories';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.use(devCors);
router.get(async (_req, res) => {
  const data = await prisma.category.findMany({ where: { active: true }, orderBy: { name: 'asc' }, select: { id: true, name: true } });
  res.status(200).json({ success: true, data });
});
router.use(auth).post(requireRoles('ADMIN'), async (req, res) => {
  const parsed = categoryCreateSchema.safeParse(req.body);
  if (!parsed.success) throw new ApiError(422, 'Datos de categoría inválidos', parsed.error.flatten().fieldErrors);
  const data = await prisma.category.create({ data: parsed.data, select: { id: true, name: true } });
  res.status(201).json({ success: true, data });
});
export default router.handler(routerOptions);
