import { z } from 'zod';

export const addressCreateSchema = z.object({
  label: z.string().trim().min(2).max(60),
  address: z.string().trim().min(8).max(500),
  reference: z.string().trim().max(500).optional(),
  latitude: z.coerce.number().min(-90).max(90).optional(),
  longitude: z.coerce.number().min(-180).max(180).optional(),
});
