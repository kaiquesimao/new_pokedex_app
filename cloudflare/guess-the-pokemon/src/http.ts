export type LeaderboardScope = 'weekly' | 'global';

export class HttpError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly status: number,
  ) {
    super(message);
    this.name = 'HttpError';
  }
}

export const MAX_REQUEST_BODY_BYTES = 8 * 1024;

export interface Pagination {
  limit: number;
  cursor?: LeaderboardCursor;
}

export interface LeaderboardCursor {
  score: number;
  achievedAt: string;
  userId: string;
}

export interface CursorOptions {
  encryptionKey: string;
  scope: LeaderboardScope;
  now?: Date;
}

const CURSOR_TTL_SECONDS = 15 * 60;
const CURSOR_IV_BYTES = 12;
const CURSOR_KEY_BYTES = 32;

export async function encodeCursor(
  cursor: LeaderboardCursor,
  options: CursorOptions,
): Promise<string> {
  validateCursor(cursor);
  const now = options.now ?? new Date();
  const key = await importCursorKey(options.encryptionKey);
  const iv = crypto.getRandomValues(new Uint8Array(CURSOR_IV_BYTES));
  const payload = new TextEncoder().encode(JSON.stringify({
    version: 1,
    scope: options.scope,
    expiresAt: Math.floor(now.getTime() / 1000) + CURSOR_TTL_SECONDS,
    score: cursor.score,
    achievedAt: cursor.achievedAt,
    userId: cursor.userId,
  }));
  const ciphertext = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv, additionalData: bufferSource(cursorAad(options.scope)) },
    key,
    payload,
  );
  return encodeBase64url(concatBytes(iv, new Uint8Array(ciphertext)));
}

const publicErrors: Record<string, { message: string; status: number }> = {
  AUTH_CONFIG_ERROR: { message: 'Authentication is not configured', status: 500 },
  AUTH_INVALID_TOKEN: { message: 'Invalid authentication token', status: 401 },
  AUTH_KEYS_UNAVAILABLE: { message: 'Authentication keys are unavailable', status: 503 },
  AUTH_REQUIRED: { message: 'Authentication is required', status: 401 },
  CURSOR_CONFIG_ERROR: { message: 'Cursor encryption is not configured', status: 500 },
  INTERNAL_ERROR: { message: 'Internal server error', status: 500 },
  INVALID_ID: { message: 'Invalid ID', status: 400 },
  INVALID_JSON: { message: 'Request body must be valid JSON', status: 400 },
  INVALID_PAGINATION: { message: 'Invalid pagination', status: 400 },
  INVALID_SCOPE: { message: 'Invalid scope', status: 400 },
  GAME_INVALID_INPUT: { message: 'Invalid game input', status: 400 },
  GAME_SESSION_NOT_FOUND: { message: 'Game session was not found', status: 404 },
  GAME_ROUND_ORDER: { message: 'Game round is out of order', status: 409 },
  GAME_SESSION_FINISHED: { message: 'Game session is finished', status: 409 },
  GAME_SESSION_EXPIRED: { message: 'Game session has expired', status: 410 },
  GAME_SESSION_CAP: { message: 'Too many active game sessions', status: 409 },
  GAME_ANSWER_CAP: { message: 'Game answer limit reached', status: 409 },
  GAME_PUBLISH_CAP: { message: 'Game publication limit reached', status: 409 },
  RATE_LIMITED: { message: 'Too many requests', status: 429 },
  REQUEST_BODY_TOO_LARGE: { message: 'Request body is too large', status: 413 },
  NOT_FOUND: { message: 'Route was not found', status: 404 },
  METHOD_NOT_ALLOWED: { message: 'Method is not allowed', status: 405 },
  INVALID_ROUND: { message: 'Invalid round request', status: 400 },
  CORS_ORIGIN_NOT_ALLOWED: { message: 'Origin is not allowed', status: 403 },
};

export function getBearerToken(request: Request): string {
  const value = request.headers.get('authorization');
  const match = value?.match(/^Bearer ([^\s]+)$/i);
  if (!match) throw new HttpError('AUTH_REQUIRED', 'Authentication is required', 401);
  return match[1];
}

export async function parseJsonBody<T extends Record<string, unknown> = Record<string, unknown>>(
  request: Request,
  maxBytes = MAX_REQUEST_BODY_BYTES,
): Promise<T> {
  const contentType = request.headers.get('content-type');
  if (contentType && !/^application\/json(?:\s*;|$)/i.test(contentType)) {
    throw new HttpError('INVALID_JSON', 'Request body must be JSON', 400);
  }
  const contentLength = request.headers.get('content-length');
  if (contentLength && (!/^\d+$/.test(contentLength) || Number(contentLength) > maxBytes)) {
    throw new HttpError('REQUEST_BODY_TOO_LARGE', 'Request body is too large', 413);
  }
  let value: unknown;
  try {
    const body = await request.text();
    if (new TextEncoder().encode(body).byteLength > maxBytes) {
      throw new HttpError('REQUEST_BODY_TOO_LARGE', 'Request body is too large', 413);
    }
    value = JSON.parse(body);
  } catch (error) {
    if (error instanceof HttpError) throw error;
    throw new HttpError('INVALID_JSON', 'Request body must be valid JSON', 400);
  }
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new HttpError('INVALID_JSON', 'Request body must be a JSON object', 400);
  }
  return value as T;
}

export async function parsePagination(url: URL, options: CursorOptions): Promise<Pagination> {
  const key = await importCursorKey(options.encryptionKey);
  const limitValues = url.searchParams.getAll('limit');
  if (limitValues.length > 1) throw new HttpError('INVALID_PAGINATION', 'Invalid pagination', 400);
  const rawLimit = limitValues[0] ?? null;
  const limit = rawLimit === null ? 50 : parsePositiveId(rawLimit, 'pagination limit');
  if (limit > 100) throw new HttpError('INVALID_PAGINATION', 'Invalid pagination', 400);
  const cursorValues = url.searchParams.getAll('cursor');
  if (cursorValues.length > 1) throw new HttpError('INVALID_PAGINATION', 'Invalid pagination', 400);
  const rawCursor = cursorValues[0];
  if (rawCursor !== undefined && (rawCursor.length === 0 || rawCursor.length > 512)) {
    throw new HttpError('INVALID_PAGINATION', 'Invalid pagination', 400);
  }
  return rawCursor === undefined ? { limit } : {
    limit,
    cursor: await parseCursor(rawCursor, options, key),
  };
}

function encodeBase64url(bytes: Uint8Array): string {
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll('+', '-').replaceAll('/', '_').replace(/=+$/, '');
}

async function parseCursor(value: string, options: CursorOptions, key: CryptoKey): Promise<LeaderboardCursor> {
  if (!/^[A-Za-z0-9_-]+$/.test(value) || value.length % 4 === 1) {
    throw new HttpError('INVALID_PAGINATION', 'Invalid pagination', 400);
  }
  try {
    const bytes = decodeBase64url(value);
    if (bytes.length <= CURSOR_IV_BYTES + 16) throw new Error();
    const iv = bytes.slice(0, CURSOR_IV_BYTES);
    const ciphertext = bytes.slice(CURSOR_IV_BYTES);
    const plaintext = await crypto.subtle.decrypt(
      { name: 'AES-GCM', iv, additionalData: bufferSource(cursorAad(options.scope)) },
      key,
      ciphertext,
    );
    const parsed: unknown = JSON.parse(new TextDecoder('utf-8', { fatal: true }).decode(plaintext));
    if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) throw new Error();
    const payload = parsed as Record<string, unknown>;
    const { version, scope, expiresAt, score, achievedAt, userId } = payload;
    if (
      version !== 1 ||
      scope !== options.scope ||
      !Number.isSafeInteger(expiresAt) ||
      (expiresAt as number) <= Math.floor((options.now ?? new Date()).getTime() / 1000) ||
      !Number.isSafeInteger(score) ||
      (score as number) < 0 ||
      typeof achievedAt !== 'string' ||
      !isCanonicalTimestamp(achievedAt) ||
      typeof userId !== 'string' ||
      userId.length === 0 ||
      userId.length > 128 ||
      userId.trim() !== userId
    ) throw new Error();
    return { score: score as number, achievedAt, userId };
  } catch {
    throw new HttpError('INVALID_PAGINATION', 'Invalid pagination', 400);
  }
}

async function importCursorKey(value: string): Promise<CryptoKey> {
  try {
    if (typeof value !== 'string' || value.length === 0) throw new Error();
    const bytes = decodeBase64url(value);
    if (bytes.length !== CURSOR_KEY_BYTES) throw new Error();
    return await crypto.subtle.importKey('raw', bufferSource(bytes), { name: 'AES-GCM' }, false, ['encrypt', 'decrypt']);
  } catch {
    throw new HttpError('CURSOR_CONFIG_ERROR', 'Cursor encryption is not configured', 500);
  }
}

function validateCursor(cursor: LeaderboardCursor): void {
  if (!Number.isSafeInteger(cursor.score) || cursor.score < 0 || !isCanonicalTimestamp(cursor.achievedAt) || !/^[^\s]{1,128}$/.test(cursor.userId)) {
    throw new HttpError('INVALID_PAGINATION', 'Invalid pagination', 400);
  }
}

function cursorAad(scope: LeaderboardScope): Uint8Array {
  return new TextEncoder().encode(`guess-the-pokemon:leaderboards:${scope}`);
}

function concatBytes(first: Uint8Array, second: Uint8Array): Uint8Array {
  const bytes = new Uint8Array(first.length + second.length);
  bytes.set(first);
  bytes.set(second, first.length);
  return bytes;
}

function decodeBase64url(value: string): Uint8Array {
  if (!/^[A-Za-z0-9_-]+$/.test(value) || value.length % 4 === 1) throw new Error();
  const base64 = value.replaceAll('-', '+').replaceAll('_', '/').padEnd(Math.ceil(value.length / 4) * 4, '=');
  const binary = atob(base64);
  const bytes = Uint8Array.from(binary, (character) => character.charCodeAt(0));
  if (encodeBase64url(bytes) !== value) throw new Error();
  return bytes;
}

function bufferSource(bytes: Uint8Array): ArrayBuffer {
  return bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength) as ArrayBuffer;
}

function isCanonicalTimestamp(value: string): boolean {
  if (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/.test(value)) return false;
  const date = new Date(value);
  return !Number.isNaN(date.getTime()) && date.toISOString() === value;
}

export function parseScope(value: string | null): LeaderboardScope {
  if (value !== 'weekly' && value !== 'global') {
    throw new HttpError('INVALID_SCOPE', 'Invalid scope', 400);
  }
  return value;
}

export function parsePositiveId(value: string | number | null, field = 'ID'): number {
  const text = String(value ?? '');
  if (!/^\d+$/.test(text)) throw new HttpError('INVALID_ID', `Invalid ${field}`, 400);
  const result = Number(text);
  if (!Number.isSafeInteger(result) || result < 1) {
    throw new HttpError('INVALID_ID', `Invalid ${field}`, 400);
  }
  return result;
}

export function jsonError(error: unknown): Response {
  const candidate = error && typeof error === 'object' && 'code' in error ? error.code : undefined;
  const code = typeof candidate === 'string' && Object.prototype.hasOwnProperty.call(publicErrors, candidate) ? candidate : 'INTERNAL_ERROR';
  const { message, status } = publicErrors[code];
  return Response.json({ error: { code, message } }, {
    status,
    headers: { 'cache-control': 'no-store' },
  });
}
