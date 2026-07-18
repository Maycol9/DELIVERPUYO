import { createHash, randomUUID } from 'node:crypto';
import { SignJWT, jwtVerify } from 'jose';
import { env } from '@/lib/config/env';

export type AccessClaims = { sub: string; email: string; role: 'CLIENT' | 'ADMIN' };
const accessKey = new TextEncoder().encode(env.JWT_ACCESS_SECRET);
const refreshKey = new TextEncoder().encode(env.JWT_REFRESH_SECRET);

export async function signAccessToken(claims: AccessClaims): Promise<string> {
  return new SignJWT({ email: claims.email, role: claims.role })
    .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
    .setSubject(claims.sub)
    .setIssuedAt()
    .setExpirationTime(`${env.ACCESS_TOKEN_MINUTES}m`)
    .sign(accessKey);
}

export async function signRefreshToken(userId: string): Promise<string> {
  return new SignJWT({ type: 'refresh' })
    .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
    .setSubject(userId)
    .setIssuedAt()
    .setJti(randomUUID())
    .setExpirationTime(`${env.REFRESH_TOKEN_DAYS}d`)
    .sign(refreshKey);
}

export async function verifyAccessToken(token: string): Promise<AccessClaims> {
  const { payload } = await jwtVerify(token, accessKey, { algorithms: ['HS256'] });
  if (!payload.sub || typeof payload.email !== 'string' || (payload.role !== 'CLIENT' && payload.role !== 'ADMIN')) {
    throw new Error('Token de acceso incompleto');
  }
  return { sub: payload.sub, email: payload.email, role: payload.role };
}

export async function verifyRefreshToken(token: string): Promise<string> {
  const { payload } = await jwtVerify(token, refreshKey, { algorithms: ['HS256'] });
  if (!payload.sub || payload.type !== 'refresh') throw new Error('Refresh token inválido');
  return payload.sub;
}

export function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}
