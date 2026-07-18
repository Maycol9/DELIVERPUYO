import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { prisma } from '@/database/client';
import { ApiError } from '@/errors/api-error';
import { routerOptions } from '@/lib/api/router-config';
import { auth } from '@/middleware/auth';
import { addressCreateSchema } from '@/validations/addresses';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.use(auth)
  .get(async (req, res) => {
    const data = await prisma.address.findMany({ where: { userId: req.user!.sub }, orderBy: { createdAt: 'desc' }, select: { id: true, label: true, address: true, reference: true, latitude: true, longitude: true } });
    res.status(200).json({ success: true, data });
  })
  .post(async (req, res) => {
    const parsed = addressCreateSchema.safeParse(req.body);
    if (!parsed.success) throw new ApiError(422, 'Datos de dirección inválidos', parsed.error.flatten().fieldErrors);
    const data = await prisma.address.create({ data: { userId: req.user!.sub, ...parsed.data }, select: { id: true, label: true, address: true, reference: true } });
    res.status(201).json({ success: true, data });
  });
export default router.handler(routerOptions);
