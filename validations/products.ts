import { z } from 'zod';

export const productQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().max(50).optional(),
  categoryId: z.string().uuid().optional(),
  search: z.string().trim().max(80).optional(),
  fields: z.string().optional(),
});

export const productCreateSchema = z.object({
  categoryId: z.string().uuid(),
  name: z.string().trim().min(3).max(150),
  description: z.string().trim().max(1000).optional(),
  price: z.coerce.number().positive().max(999999),
  stock: z.coerce.number().int().nonnegative(),
  imageUrl: z.string().url().optional(),
});

export const productUpdateSchema = productCreateSchema.partial().refine((v) => Object.keys(v).length > 0, 'Debe enviar al menos un campo');
