import type { MiddlewareHandler } from 'hono';

import { HttpError, jsonError } from '../http';

const KNOWN_PATHS = new Set([
  '/round',
  '/v1/leaderboards',
  '/v1/me/game-profile',
]);

function isKnownPath(pathname: string): boolean {
  return KNOWN_PATHS.has(pathname) || pathname.startsWith('/v1/game/');
}

function allowedOrigins(env: Cloudflare.Env): Set<string> {
  const configured =
    (env as Cloudflare.Env & { CORS_ALLOWED_ORIGINS?: string }).CORS_ALLOWED_ORIGINS ?? '';
  return new Set(
    configured.split(',').map((origin: string) => origin.trim()).filter(Boolean),
  );
}

/** Flutter web / Chrome local debugging (Android/iOS clients do not send Origin). */
function isLocalDevOrigin(origin: string): boolean {
  try {
    const url = new URL(origin);
    return url.protocol === 'http:'
      && (url.hostname === 'localhost' || url.hostname === '127.0.0.1');
  } catch {
    return false;
  }
}

export function isAllowedOrigin(origin: string, env: Cloudflare.Env): boolean {
  return allowedOrigins(env).has(origin) || isLocalDevOrigin(origin);
}

function applyCorsHeaders(headers: Headers, origin: string | undefined, env: Cloudflare.Env): void {
  headers.set('vary', 'Origin');
  if (origin && isAllowedOrigin(origin, env)) {
    headers.set('access-control-allow-origin', origin);
    headers.set('access-control-allow-methods', 'GET, POST, PATCH, OPTIONS');
    // Flutter web Dio sends X-PokeData-Client; omitting it fails browser preflight.
    headers.set(
      'access-control-allow-headers',
      'Authorization, Content-Type, X-PokeData-Client',
    );
    headers.set('access-control-max-age', '600');
  }
}

export function withCors(
  response: Response,
  origin: string | undefined,
  env: Cloudflare.Env,
): Response {
  const headers = new Headers(response.headers);
  applyCorsHeaders(headers, origin, env);
  return new Response(response.body, { status: response.status, headers });
}

/**
 * Rejects disallowed Origins with a stable JSON envelope, answers OPTIONS
 * preflight for known paths, and attaches CORS headers to every response.
 */
export function corsMiddleware(): MiddlewareHandler<{ Bindings: Cloudflare.Env }> {
  return async (c, next) => {
    const origin = c.req.header('origin');
    if (origin && !isAllowedOrigin(origin, c.env)) {
      return withCors(
        jsonError(new HttpError('CORS_ORIGIN_NOT_ALLOWED', 'Origin is not allowed', 403)),
        origin,
        c.env,
      );
    }
    if (c.req.method === 'OPTIONS') {
      if (!isKnownPath(c.req.path)) {
        return withCors(
          jsonError(new HttpError('NOT_FOUND', 'Route was not found', 404)),
          origin,
          c.env,
        );
      }
      return withCors(new Response(null, { status: 204 }), origin, c.env);
    }
    await next();
    applyCorsHeaders(c.res.headers, origin, c.env);
  };
}
