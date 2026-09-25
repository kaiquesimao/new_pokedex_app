import type { MiddlewareHandler } from 'hono';

import { HttpError, MAX_REQUEST_BODY_BYTES } from '../http';

/**
 * Ensures the request body is empty (and within the size cap).
 * Use on endpoints that must not accept a payload.
 */
export function requireEmptyBody(
  maxBytes = MAX_REQUEST_BODY_BYTES,
): MiddlewareHandler {
  return async (c, next) => {
    const value = c.req.header('content-length');
    if (value && (!/^\d+$/.test(value) || Number(value) > maxBytes)) {
      throw new HttpError('REQUEST_BODY_TOO_LARGE', 'Request body is too large', 413);
    }
    const bytes = c.req.raw.body ? await c.req.raw.arrayBuffer() : null;
    const size = bytes?.byteLength ?? 0;
    if (size > maxBytes) {
      throw new HttpError('REQUEST_BODY_TOO_LARGE', 'Request body is too large', 413);
    }
    if (size > 0) {
      throw new HttpError('INVALID_JSON', 'Request body must be empty', 400);
    }
    await next();
  };
}
