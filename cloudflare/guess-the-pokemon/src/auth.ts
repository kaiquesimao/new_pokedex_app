const FIREBASE_KEYS_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com';
const CLOCK_SKEW_SECONDS = 300;

export class AuthError extends Error {
  constructor(public readonly code: string, message: string, public readonly status = 401) {
    super(message);
    this.name = 'AuthError';
  }
}

export interface FirebaseClaims {
  iss: string;
  aud: string;
  sub: string;
  iat: number;
  exp: number;
  [claim: string]: unknown;
}

interface VerifyOptions {
  now?: number;
  fetcher?: typeof fetch;
}

export interface FirebaseAuthEnv {
  FIREBASE_PROJECT_ID: string;
}

interface CachedKeys {
  expiresAt: number;
  keys: Map<string, CryptoKey>;
}

let cachedKeys: CachedKeys | undefined;

function invalidToken(): AuthError {
  return new AuthError('AUTH_INVALID_TOKEN', 'Invalid authentication token');
}

function keysUnavailable(): AuthError {
  return new AuthError('AUTH_KEYS_UNAVAILABLE', 'Authentication keys are unavailable', 503);
}

function bufferSource(bytes: Uint8Array): ArrayBuffer {
  return bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength) as ArrayBuffer;
}

function decodePart(value: string): Uint8Array {
  if (!/^[A-Za-z0-9_-]+$/.test(value)) throw invalidToken();
  const base64 = value.replaceAll('-', '+').replaceAll('_', '/').padEnd(Math.ceil(value.length / 4) * 4, '=');
  try {
    const binary = atob(base64);
    return Uint8Array.from(binary, (character) => character.charCodeAt(0));
  } catch {
    throw invalidToken();
  }
}

function parseJson(value: string): Record<string, unknown> {
  try {
    const parsed: unknown = JSON.parse(value);
    if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) throw new Error();
    return parsed as Record<string, unknown>;
  } catch {
    throw invalidToken();
  }
}

function readTlv(bytes: Uint8Array, offset: number): { end: number; start: number; tag: number } {
  const start = offset;
  if (offset >= bytes.length) throw invalidToken();
  const tag = bytes[offset++];
  if (bytes[offset] === undefined) throw invalidToken();
  let length = bytes[offset++];
  if (length & 0x80) {
    const count = length & 0x7f;
    if (count === 0 || count > 4 || offset + count > bytes.length) throw invalidToken();
    length = 0;
    for (let index = 0; index < count; index++) length = length * 256 + bytes[offset++];
  }
  const end = offset + length;
  if (end > bytes.length) throw invalidToken();
  return { end, start, tag };
}

function spkiFromCertificate(certificate: Uint8Array): Uint8Array {
  const outer = readTlv(certificate, 0);
  if (outer.tag !== 0x30) throw invalidToken();
  let offset = 1;
  let length = certificate[offset++];
  if (length & 0x80) {
    const count = length & 0x7f;
    length = 0;
    for (let index = 0; index < count; index++) length = length * 256 + certificate[offset++];
  }
  const tbs = readTlv(certificate, offset);
  if (tbs.tag !== 0x30) throw invalidToken();
  offset = tbs.start + 1;
  length = certificate[offset++];
  if (length & 0x80) {
    const count = length & 0x7f;
    offset += count;
  }
  const version = readTlv(certificate, offset);
  if (version.tag === 0xa0) offset = version.end;
  for (let index = 0; index < 5; index++) offset = readTlv(certificate, offset).end;
  const spki = readTlv(certificate, offset);
  return certificate.slice(spki.start, spki.end);
}

function pemBytes(value: string): Uint8Array {
  const match = value.match(/-----BEGIN ([A-Z ]+)-----([\s\S]+?)-----END \1-----/);
  if (!match) throw invalidToken();
  const base64 = match[2].replace(/\s/g, '');
  try {
    const binary = atob(base64);
    const bytes = Uint8Array.from(binary, (character) => character.charCodeAt(0));
    return match[1] === 'CERTIFICATE' ? spkiFromCertificate(bytes) : bytes;
  } catch {
    throw invalidToken();
  }
}

async function fetchKeys(fetcher: typeof fetch): Promise<CachedKeys> {
  try {
    const response = await fetcher(FIREBASE_KEYS_URL);
    if (!response.ok) throw keysUnavailable();
    const values: unknown = await response.json();
    if (values === null || typeof values !== 'object' || Array.isArray(values)) throw keysUnavailable();
    const keys = new Map<string, CryptoKey>();
    for (const [kid, value] of Object.entries(values)) {
      if (typeof value !== 'string') throw keysUnavailable();
      keys.set(kid, await crypto.subtle.importKey('spki', bufferSource(pemBytes(value)), { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['verify']));
    }
    if (keys.size === 0) throw keysUnavailable();
    const maxAge = Number(response.headers.get('cache-control')?.match(/max-age=(\d+)/i)?.[1] ?? 3600);
    cachedKeys = { keys, expiresAt: Date.now() + (Number.isFinite(maxAge) ? maxAge : 3600) * 1000 };
    return cachedKeys;
  } catch (error) {
    if (error instanceof AuthError && error.code === 'AUTH_KEYS_UNAVAILABLE') throw error;
    throw keysUnavailable();
  }
}

export async function verifyFirebaseIdToken(token: string, env: FirebaseAuthEnv, options: VerifyOptions = {}): Promise<FirebaseClaims> {
  if (!env.FIREBASE_PROJECT_ID) throw new AuthError('AUTH_CONFIG_ERROR', 'Authentication is not configured', 500);
  const parts = token.split('.');
  if (parts.length !== 3) throw invalidToken();
  const header = parseJson(new TextDecoder().decode(decodePart(parts[0])));
  const claims = parseJson(new TextDecoder().decode(decodePart(parts[1])));
  if (header.alg !== 'RS256' || typeof header.kid !== 'string' || !header.kid) throw invalidToken();
  if (typeof claims.iss !== 'string' || claims.iss !== `https://securetoken.google.com/${env.FIREBASE_PROJECT_ID}` || claims.aud !== env.FIREBASE_PROJECT_ID || typeof claims.sub !== 'string' || claims.sub.length === 0 || claims.sub.length > 128 || !Number.isInteger(claims.iat) || !Number.isInteger(claims.exp)) throw invalidToken();
  const issuedAt = claims.iat as number;
  const expiresAt = claims.exp as number;
  const now = options.now ?? Math.floor(Date.now() / 1000);
  if (expiresAt <= now || issuedAt > now + CLOCK_SKEW_SECONDS || expiresAt <= issuedAt) throw invalidToken();
  const keys = cachedKeys && cachedKeys.expiresAt > Date.now() ? cachedKeys : await fetchKeys(options.fetcher ?? fetch);
  let key = keys.keys.get(header.kid);
  if (!key) key = (await fetchKeys(options.fetcher ?? fetch)).keys.get(header.kid);
  if (!key) throw keysUnavailable();
  const verified = await crypto.subtle.verify('RSASSA-PKCS1-v1_5', key, bufferSource(decodePart(parts[2])), new TextEncoder().encode(`${parts[0]}.${parts[1]}`));
  if (!verified) throw invalidToken();
  return claims as unknown as FirebaseClaims;
}
