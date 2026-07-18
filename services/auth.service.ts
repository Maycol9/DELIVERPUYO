import bcrypt from 'bcryptjs';
import { prisma } from '@/database/client';
import { ApiError } from '@/errors/api-error';
import { env } from '@/lib/config/env';
import { hashToken, signAccessToken, signRefreshToken, verifyRefreshToken } from '@/lib/jwt';

async function issueTokens(user: { id: string; email: string; role: 'CLIENT' | 'ADMIN' }) {
  const accessToken = await signAccessToken({ sub: user.id, email: user.email, role: user.role });
  const refreshToken = await signRefreshToken(user.id);
  await prisma.refreshToken.create({
    data: {
      userId: user.id,
      tokenHash: hashToken(refreshToken),
      expiresAt: new Date(Date.now() + env.REFRESH_TOKEN_DAYS * 86400000),
    },
  });
  return { accessToken, refreshToken, expiresInSeconds: env.ACCESS_TOKEN_MINUTES * 60 };
}

export const authService = {
  async register(data: { name: string; email: string; password: string }) {
    const exists = await prisma.user.findUnique({ where: { email: data.email }, select: { id: true } });
    if (exists) throw new ApiError(409, 'El correo ya se encuentra registrado');
    const user = await prisma.user.create({
      data: { name: data.name, email: data.email, passwordHash: await bcrypt.hash(data.password, 12) },
      select: { id: true, name: true, email: true, role: true },
    });
    return { user, ...(await issueTokens(user)) };
  },

  async login(email: string, password: string) {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !user.active || !(await bcrypt.compare(password, user.passwordHash))) {
      throw new ApiError(401, 'Credenciales inválidas');
    }
    return { user: { id: user.id, name: user.name, email: user.email, role: user.role }, ...(await issueTokens(user)) };
  },

  async refresh(rawToken: string) {
    const userId = await verifyRefreshToken(rawToken).catch(() => { throw new ApiError(401, 'Refresh token inválido o expirado'); });
    const stored = await prisma.refreshToken.findUnique({ where: { tokenHash: hashToken(rawToken) }, include: { user: true } });
    if (!stored || stored.userId !== userId || stored.revokedAt || stored.expiresAt <= new Date() || !stored.user.active) {
      throw new ApiError(401, 'Refresh token revocado o expirado');
    }
    await prisma.refreshToken.update({ where: { id: stored.id }, data: { revokedAt: new Date() } });
    return issueTokens(stored.user);
  },
};
