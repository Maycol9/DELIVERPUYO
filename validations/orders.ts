import { z } from 'zod';

export const createOrderSchema = z.object({
  addressId: z.string().uuid(),
  items: z.array(z.object({ productId: z.string().uuid(), quantity: z.coerce.number().int().positive().max(50) })).min(1).max(30),
});
