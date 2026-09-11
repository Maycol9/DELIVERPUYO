import type { NextApiRequest, NextApiResponse } from 'next';
import { createRouter } from 'next-connect';
import { prisma } from '@/database/client';
import { ApiError } from '@/errors/api-error';
import { routerOptions } from '@/lib/api/router-config';
import { auth } from '@/middleware/auth';
import { addressCreateSchema } from '@/validations/addresses';
import { pagination } from '@/helper/pagination';

const router = createRouter<NextApiRequest, NextApiResponse>();
router.use(auth)
  .get(async (req, res) => {
    const p = pagination(req.query.page, req.query.limit);
    const where = { userId: req.user!.sub };
    const [data, total] = await prisma.$transaction([
      prisma.address.findMany({ where, skip: p.skip, take: p.limit, orderBy: { createdAt: 'desc' }, select: { id: true, label: true, address: true, reference: true, latitude: true, longitude: true } }),
      prisma.address.count({ where }),
    ]);
    res.status(200).json({ success: true, data, pagination: p.meta(total) });
  })
  .post(async (req, res) => {
    const parsed = addressCreateSchema.safeParse(req.body);
    if (!parsed.success) throw new ApiError(422, 'Datos de dirección inválidos', parsed.error.flatten().fieldErrors);
    const data = await prisma.address.create({ data: { userId: req.user!.sub, ...parsed.data }, select: { id: true, label: true, address: true, reference: true } });
    res.status(201).json({ success: true, data });
  });
export default router.handler(routerOptions);
