import type { AccessClaims } from '@/lib/jwt';

declare module 'next' {
  interface NextApiRequest {
    user?: AccessClaims;
  }
}
