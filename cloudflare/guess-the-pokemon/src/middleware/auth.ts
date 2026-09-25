import type { MiddlewareHandler } from 'hono';

import {
  verifyFirebaseIdToken,
  type FirebaseAuthEnv,
  type FirebaseClaims,
} from '../auth';
import { getBearerToken } from '../http';

export type AuthVerifier = (
  token: string,
  env: FirebaseAuthEnv,
) => Promise<FirebaseClaims>;

export type AuthVariables = {
  userId: string;
  claims: FirebaseClaims;
};

export type OptionalAuthVariables = {
  userId?: string;
  claims: FirebaseClaims | null;
};

type AuthBindings = FirebaseAuthEnv;

/**
 * Requires a valid Bearer Firebase ID token and sets `userId` / `claims`.
 */
export function requireAuth(
  verifyToken: AuthVerifier = verifyFirebaseIdToken,
): MiddlewareHandler<{ Bindings: AuthBindings; Variables: AuthVariables }> {
  return async (c, next) => {
    const claims = await verifyToken(getBearerToken(c.req.raw), c.env);
    c.set('claims', claims);
    c.set('userId', claims.sub);
    await next();
  };
}

/**
 * Verifies the Bearer token when present; otherwise continues as a guest.
 */
export function optionalAuth(
  verifyToken: AuthVerifier = verifyFirebaseIdToken,
): MiddlewareHandler<{ Bindings: AuthBindings; Variables: OptionalAuthVariables }> {
  return async (c, next) => {
    const authorization = c.req.header('authorization');
    if (!authorization) {
      c.set('claims', null);
      await next();
      return;
    }
    const claims = await verifyToken(getBearerToken(c.req.raw), c.env);
    c.set('claims', claims);
    c.set('userId', claims.sub);
    await next();
  };
}
