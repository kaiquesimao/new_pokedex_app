import { describe, expect, it } from 'vitest';

import { AuthError } from '../src/auth';
import {
  HttpError,
  encodeCursor,
  getBearerToken,
  jsonError,
  parseJsonBody,
  parsePagination,
  parsePositiveId,
  parseScope,
} from '../src/http';

const cursorKey = base64url(new Uint8Array(32).fill(7));

function base64url(bytes: Uint8Array): string {
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll('+', '-').replaceAll('/', '_').replace(/=+$/, '');
}

describe('http validation', () => {
  it('extracts only a valid bearer token', () => {
    expect(getBearerToken(new Request('https://test', { headers: { authorization: 'Bearer abc.def' } }))).toBe('abc.def');
    expect(() => getBearerToken(new Request('https://test'))).toThrowError(new HttpError('AUTH_REQUIRED', 'Authentication is required', 401));
    expect(() => getBearerToken(new Request('https://test', { headers: { authorization: 'Basic abc' } }))).toThrow('Authentication is required');
  });

  it('parses strict JSON objects and rejects malformed or oversized bodies', async () => {
    const request = new Request('https://test', { method: 'POST', headers: { 'content-type': 'application/json' }, body: '{"name":"Pikachu"}' });
    await expect(parseJsonBody(request)).resolves.toEqual({ name: 'Pikachu' });
    await expect(parseJsonBody(new Request('https://test', { method: 'POST', body: '[]' }))).rejects.toMatchObject({ code: 'INVALID_JSON' });
    await expect(parseJsonBody(new Request('https://test', { method: 'POST', body: '{bad' }))).rejects.toMatchObject({ code: 'INVALID_JSON' });
  });

  it('validates pagination, scopes, and positive IDs', async () => {
    const cursor = await encodeCursor({ score: 12, achievedAt: '2026-09-17T12:00:00.000Z', userId: 'firebase-user' }, {
      encryptionKey: cursorKey,
      scope: 'global',
      now: new Date('2026-09-17T12:00:00.000Z'),
    });
    await expect(parsePagination(new URL(`https://test?limit=25&cursor=${cursor}`), {
      encryptionKey: cursorKey,
      scope: 'global',
      now: new Date('2026-09-17T12:00:00.000Z'),
    })).resolves.toEqual({
      limit: 25,
      cursor: { score: 12, achievedAt: '2026-09-17T12:00:00.000Z', userId: 'firebase-user' },
    });
    await expect(parsePagination(new URL('https://test?limit=0'), {
      encryptionKey: cursorKey,
      scope: 'global',
    })).rejects.toThrow('Invalid pagination');
    expect(parseScope('weekly')).toBe('weekly');
    expect(() => parseScope('all')).toThrow('Invalid scope');
    expect(parsePositiveId('25', 'pokemonId')).toBe(25);
    expect(() => parsePositiveId('0', 'pokemonId')).toThrow('Invalid pokemonId');
    expect(() => parsePositiveId('1.5', 'pokemonId')).toThrow('Invalid pokemonId');
  });

  it.each([
    ['not-base64', 'not-base64'],
    ['whitespace', 'abc '],
    ['tampered', `${base64url(new Uint8Array(80).fill(1))}`],
  ])('rejects malformed opaque cursor: %s', async (_name, cursor) => {
    await expect(parsePagination(new URL(`https://test?cursor=${encodeURIComponent(cursor)}`), {
      encryptionKey: cursorKey,
      scope: 'global',
    })).rejects.toThrow('Invalid pagination');
  });

  it('rejects duplicate, oversized, expired, cross-scope, and missing-key cursors', async () => {
    const cursor = await encodeCursor({ score: 12, achievedAt: '2026-09-17T12:00:00.000Z', userId: 'firebase-user' }, {
      encryptionKey: cursorKey,
      scope: 'global',
      now: new Date('2026-09-17T12:00:00.000Z'),
    });
    await expect(parsePagination(new URL(`https://test?cursor=${cursor}&cursor=${cursor}`), {
      encryptionKey: cursorKey,
      scope: 'global',
    })).rejects.toThrow('Invalid pagination');
    await expect(parsePagination(new URL(`https://test?cursor=${'a'.repeat(513)}`), {
      encryptionKey: cursorKey,
      scope: 'global',
    })).rejects.toThrow('Invalid pagination');
    await expect(parsePagination(new URL(`https://test?cursor=${cursor}`), {
      encryptionKey: cursorKey,
      scope: 'weekly',
      now: new Date('2026-09-17T12:00:00.000Z'),
    })).rejects.toThrow('Invalid pagination');
    await expect(parsePagination(new URL(`https://test?cursor=${cursor}`), {
      encryptionKey: cursorKey,
      scope: 'global',
      now: new Date('2026-09-17T12:16:00.000Z'),
    })).rejects.toThrow('Invalid pagination');
    await expect(parsePagination(new URL(`https://test?cursor=${cursor}`), {
      encryptionKey: '',
      scope: 'global',
    })).rejects.toMatchObject({ code: 'CURSOR_CONFIG_ERROR' });
    expect(cursor).not.toContain('firebase-user');
  });

  it('returns stable JSON error responses', async () => {
    const response = jsonError(new HttpError('INVALID_SCOPE', 'Invalid scope', 400));
    expect(response.status).toBe(400);
    expect(response.headers.get('content-type')).toContain('application/json');
    await expect(response.json()).resolves.toEqual({ error: { code: 'INVALID_SCOPE', message: 'Invalid scope' } });
  });

  it('maps auth and unknown failures without leaking implementation details', async () => {
    const keyResponse = jsonError(new AuthError('AUTH_KEYS_UNAVAILABLE', 'upstream secret', 503));
    await expect(keyResponse.json()).resolves.toEqual({ error: { code: 'AUTH_KEYS_UNAVAILABLE', message: 'Authentication keys are unavailable' } });
    const unknownResponse = jsonError(new Error('private upstream details'));
    expect(unknownResponse.status).toBe(500);
    await expect(unknownResponse.json()).resolves.toEqual({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error' } });
    const secretResponse = jsonError(new HttpError('INTERNAL_ERROR', 'database password', 500));
    await expect(secretResponse.json()).resolves.toEqual({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error' } });
    const prototypeKeyResponse = jsonError({ code: '__proto__', message: 'prototype details' });
    expect(prototypeKeyResponse.status).toBe(500);
    await expect(prototypeKeyResponse.json()).resolves.toEqual({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error' } });
  });
});
