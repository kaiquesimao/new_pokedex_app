import { afterEach, describe, expect, it, vi } from 'vitest';

import { AuthError, verifyFirebaseIdToken, type FirebaseAuthEnv } from '../src/auth';

const projectId = 'pokemon-project';

function base64url(value: ArrayBuffer | string): string {
  const bytes = typeof value === 'string' ? new TextEncoder().encode(value) : new Uint8Array(value);
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll('+', '-').replaceAll('/', '_').replace(/=+$/, '');
}

async function makeToken(privateKey: CryptoKey, claims: Record<string, unknown>, kid = 'key-1'): Promise<string> {
  const header = base64url(JSON.stringify({ alg: 'RS256', kid, typ: 'JWT' }));
  const payload = base64url(JSON.stringify(claims));
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    privateKey,
    new TextEncoder().encode(`${header}.${payload}`),
  );
  return `${header}.${payload}.${base64url(signature)}`;
}

async function setup() {
  const pair = await crypto.subtle.generateKey(
    { name: 'RSASSA-PKCS1-v1_5', modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: 'SHA-256' },
    true,
    ['sign', 'verify'],
  ) as CryptoKeyPair;
  const spki = await crypto.subtle.exportKey('spki', pair.publicKey);
  const key = `-----BEGIN PUBLIC KEY-----\n${base64url(spki).replaceAll('-', '+').replaceAll('_', '/')}\n-----END PUBLIC KEY-----`;
  const now = 1_700_000_000;
  const fetcher = vi.fn(async () => new Response(JSON.stringify({ 'key-1': key }), {
    headers: { 'cache-control': 'public, max-age=300' },
  }));
  return { pair, now, fetcher };
}

afterEach(() => vi.restoreAllMocks());

describe('verifyFirebaseIdToken', () => {
  it('verifies a signed Firebase token and caches public keys', async () => {
    const { pair, now, fetcher } = await setup();
    const token = await makeToken(pair.privateKey, {
      iss: `https://securetoken.google.com/${projectId}`,
      aud: projectId,
      sub: 'firebase-user',
      iat: now - 10,
      exp: now + 300,
    });
    const env = { FIREBASE_PROJECT_ID: projectId } satisfies FirebaseAuthEnv;

    await expect(verifyFirebaseIdToken(token, env, { now, fetcher })).resolves.toMatchObject({ sub: 'firebase-user' });
    await expect(verifyFirebaseIdToken(token, env, { now: now + 1, fetcher })).resolves.toMatchObject({ sub: 'firebase-user' });
    expect(fetcher).toHaveBeenCalledTimes(1);
  });

  it.each([
    ['wrong issuer', { iss: 'https://securetoken.google.com/other' }],
    ['wrong audience', { aud: 'other' }],
    ['missing subject', { sub: '' }],
    ['expired', { exp: 1_699_999_999 }],
    ['issued in the future', { iat: 1_700_000_301 }],
  ])('rejects tokens with %s', async (_name, override) => {
    const { pair, now, fetcher } = await setup();
    const token = await makeToken(pair.privateKey, {
      iss: `https://securetoken.google.com/${projectId}`, aud: projectId, sub: 'user', iat: now - 10, exp: now + 300, ...override,
    });
    await expect(verifyFirebaseIdToken(token, { FIREBASE_PROJECT_ID: projectId }, { now, fetcher }))
      .rejects.toMatchObject({ code: 'AUTH_INVALID_TOKEN' } satisfies Partial<AuthError>);
  });

  it('rejects a token with a modified signature', async () => {
    const { pair, now, fetcher } = await setup();
    const token = await makeToken(pair.privateKey, {
      iss: `https://securetoken.google.com/${projectId}`, aud: projectId, sub: 'user', iat: now - 10, exp: now + 300,
    });
    const modified = `${token.slice(0, -1)}${token.endsWith('A') ? 'B' : 'A'}`;
    await expect(verifyFirebaseIdToken(modified, { FIREBASE_PROJECT_ID: projectId }, { now, fetcher }))
      .rejects.toMatchObject({ code: 'AUTH_INVALID_TOKEN' });
  });

  it('reports a successful key refresh without the rotated kid as unavailable', async () => {
    const { pair, now, fetcher } = await setup();
    const token = await makeToken(pair.privateKey, {
      iss: `https://securetoken.google.com/${projectId}`, aud: projectId, sub: 'user', iat: now - 10, exp: now + 300,
    }, 'rotated-key');
    await expect(verifyFirebaseIdToken(token, { FIREBASE_PROJECT_ID: projectId }, { now, fetcher }))
      .rejects.toMatchObject({ code: 'AUTH_KEYS_UNAVAILABLE', status: 503 });
  });

  it.each([
    ['network failure', async () => { throw new Error('connection details'); }],
    ['invalid JSON', async () => new Response('{bad')],
    ['invalid public key', async () => new Response(JSON.stringify({ 'bad-key': 'not-a-key' }))],
  ])('maps key service %s to a safe stable error', async (_name, fetcher) => {
    const { pair, now } = await setup();
    const token = await makeToken(pair.privateKey, {
      iss: `https://securetoken.google.com/${projectId}`, aud: projectId, sub: 'user', iat: now - 10, exp: now + 300,
    }, `missing-${_name}`);
    await expect(verifyFirebaseIdToken(token, { FIREBASE_PROJECT_ID: projectId }, { now, fetcher }))
      .rejects.toMatchObject({ code: 'AUTH_KEYS_UNAVAILABLE', status: 503, message: 'Authentication keys are unavailable' });
  });
});
