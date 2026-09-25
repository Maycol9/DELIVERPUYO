import type { Prisma } from '@/generated/prisma/client';
import { prisma } from '@/database/client';
import { ApiError } from '@/errors/api-error';
import { pagination } from '@/helper/pagination';
import { env } from '@/lib/config/env';
import { ensureRedis, invalidatePattern, redis } from '@/lib/redis';

const allowedFields = new Set(['id', 'name', 'price', 'stock', 'imageUrl', 'status', 'category']);

function selectFromFields(fieldsRaw?: string): Prisma.ProductSelect {
  const requested = (fieldsRaw ?? 'id,name,price,stock,imageUrl,category').split(',').map((f) => f.trim()).filter((f) => allowedFields.has(f));
  const select: Prisma.ProductSelect = {};
  for (const field of requested) {
    if (field === 'category') select.category = { select: { id: true, name: true } };
    else (select as Record<string, boolean>)[field] = true;
  }
  if (!select.id) select.id = true;
  return select;
}

export const productService = {
  async list(query: { page?: number; limit?: number; categoryId?: string; search?: string; fields?: string }, bypassCache = false) {
    const p = pagination(query.page, query.limit);
    const cacheKey = `products:list:${p.page}:${p.limit}:${query.categoryId ?? 'all'}:${query.search ?? ''}:${query.fields ?? 'default'}`;
    if (!bypassCache) {
      try {
        await ensureRedis();
        const cached = await redis.get(cacheKey);
        if (cached) return { ...JSON.parse(cached), cache: 'HIT' as const };
      } catch (error) { console.warn('Redis no disponible; se continúa sin caché', error); }
    }

    const where: Prisma.ProductWhereInput = {
      status: 'ACTIVE',
      ...(query.categoryId ? { categoryId: query.categoryId } : {}),
      ...(query.search ? { name: { contains: query.search, mode: 'insensitive' } } : {}),
    };
    const [data, total] = await prisma.$transaction([
      prisma.product.findMany({ where, skip: p.skip, take: p.limit, orderBy: { name: 'asc' }, select: selectFromFields(query.fields) }),
      prisma.product.count({ where }),
    ]);
    const result = { success: true, data, pagination: p.meta(total), cache: (bypassCache ? 'BYPASS' : 'MISS') as 'BYPASS' | 'MISS' };
    if (!bypassCache) {
      try {
        await ensureRedis();
        await redis.set(cacheKey, JSON.stringify(result), 'EX', env.PRODUCT_CACHE_TTL_SECONDS);
      } catch (error) { console.warn('No fue posible escribir en Redis', error); }
    }
    return result;
  },

  async create(data: { categoryId: string; name: string; description?: string; price: number; stock: number; imageUrl?: string }) {
    const product = await prisma.product.create({ data, select: { id: true, name: true, price: true, stock: true, categoryId: true } });
    await invalidatePattern('products:list:*').catch(() => 0);
    return product;
  },

  async update(id: string, data: Prisma.ProductUncheckedUpdateInput) {
    const exists = await prisma.product.findUnique({ where: { id }, select: { id: true } });
    if (!exists) throw new ApiError(404, 'Producto no encontrado');
    const product = await prisma.product.update({ where: { id }, data, select: { id: true, name: true, price: true, stock: true, status: true } });
    await Promise.allSettled([invalidatePattern('products:list:*'), redis.del(`product:${id}`)]);
    return product;
  },
};
