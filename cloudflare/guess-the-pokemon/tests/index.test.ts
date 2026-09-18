import { env } from 'cloudflare:workers';
import { applyD1Migrations } from 'cloudflare:test';
import { beforeAll, beforeEach, describe, expect, it } from 'vitest';

import worker from '../src/index';

const testEnv = env as typeof env & {
  DB: D1Database;
  CORS_ALLOWED_ORIGINS: string;
  TEST_MIGRATIONS: Parameters<typeof applyD1Migrations>[1];
};

beforeAll(async () => {
  testEnv.CORS_ALLOWED_ORIGINS = 'https://app.example.test, https://admin.example.test';
  await applyD1Migrations(testEnv.DB, testEnv.TEST_MIGRATIONS);
});

beforeEach(async () => {
  await testEnv.DB.exec(`
    DELETE FROM rate_limit_buckets;
    DELETE FROM global_records;
    DELETE FROM weekly_records;
    DELETE FROM accepted_results;
    DELETE FROM game_sessions;
    DELETE FROM public_players;
  `);
});

describe('top-level Worker routing', () => {
  it('returns a CORS-enabled round response for valid input', async () => {
    const response = await worker.fetch(new Request('https://test/round?seed=a&round=1', {
      headers: { origin: 'https://app.example.test' },
    }), testEnv);

    expect(response.status).toBe(200);
    expect(response.headers.get('access-control-allow-origin')).toBe('https://app.example.test');
    await expect(response.json()).resolves.toMatchObject({ difficulty: 'easy' });
  });

  it.each([
    ['/missing', 'GET', 'NOT_FOUND'],
    ['/round?round=nope', 'GET', 'INVALID_ROUND'],
    ['/round', 'POST', 'METHOD_NOT_ALLOWED'],
    ['/v1/game/sessions', 'GET', 'AUTH_REQUIRED'],
  ])('returns the stable envelope for %s %s', async (path, method, code) => {
    const response = await worker.fetch(new Request(`https://test${path}`, {
      method,
      headers: { origin: 'https://app.example.test' },
    }), testEnv);

    expect(response.headers.get('content-type')).toContain('application/json');
    expect(response.headers.get('access-control-allow-origin')).toBe('https://app.example.test');
    await expect(response.json()).resolves.toEqual({ error: { code, message: expect.any(String) } });
  });

  it('handles OPTIONS without authentication and rejects unknown origins', async () => {
    const preflight = await worker.fetch(new Request('https://test/v1/game/sessions', {
      method: 'OPTIONS',
      headers: {
        origin: 'https://app.example.test',
        'access-control-request-method': 'POST',
      },
    }), testEnv);
    expect(preflight.status).toBe(204);
    expect(preflight.headers.get('access-control-allow-methods')).toContain('POST');

    const rejected = await worker.fetch(new Request('https://test/round', {
      headers: { origin: 'https://evil.example.test' },
    }), testEnv);
    expect(rejected.status).toBe(403);
    await expect(rejected.json()).resolves.toMatchObject({ error: { code: 'CORS_ORIGIN_NOT_ALLOWED' } });
  });

  it('routes game endpoints through authentication with the stable CORS envelope', async () => {
    const response = await worker.fetch(new Request('https://test/v1/game/sessions', {
      method: 'POST',
      headers: { origin: 'https://app.example.test' },
    }), testEnv);

    expect(response.status).toBe(401);
    expect(response.headers.get('access-control-allow-origin')).toBe('https://app.example.test');
    await expect(response.json()).resolves.toMatchObject({ error: { code: 'AUTH_REQUIRED' } });
  });

  it('sets cache-control and Vary: Origin on success and error responses', async () => {
    const ok = await worker.fetch(new Request('https://test/round?seed=a&round=1', {
      headers: { origin: 'https://app.example.test' },
    }), testEnv);
    expect(ok.headers.get('vary')).toBe('Origin');
    expect(ok.headers.get('access-control-allow-origin')).toBe('https://app.example.test');

    const unauthorized = await worker.fetch(new Request('https://test/v1/game/sessions', {
      method: 'POST',
      headers: { origin: 'https://app.example.test' },
    }), testEnv);
    expect(unauthorized.status).toBe(401);
    expect(unauthorized.headers.get('cache-control')).toBe('no-store');
    expect(unauthorized.headers.get('vary')).toBe('Origin');
    expect(unauthorized.headers.get('access-control-allow-origin')).toBe('https://app.example.test');
  });
});
