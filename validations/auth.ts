import { z } from 'zod';

export const registerSchema = z.object({
  name: z.string().trim().min(3).max(120),
  email: z.string().trim().toLowerCase().email(),
  password: z.string().min(8).max(100).regex(/[A-Z]/, 'Debe incluir una mayúscula').regex(/[0-9]/, 'Debe incluir un número'),
});

export const loginSchema = z.object({
  email: z.string().trim().toLowerCase().email(),
  password: z.string().min(1),
});

export const refreshSchema = z.object({ refreshToken: z.string().min(20) });
