import { applyD1Migrations } from 'cloudflare:test';
import { env } from 'cloudflare:workers';
import { beforeAll, beforeEach, describe, expect, it } from 'vitest';

import sharedContract from '../fixtures/game-contract.json';
import { createGameRouter, type GameAuthVerifier } from '../src/routes/game';

const testEnv = env as typeof env & {
  DB: D1Database;
  TEST_MIGRATIONS: Parameters<typeof applyD1Migrations>[1];
  FIREBASE_PROJECT_ID: string;
};

const verify: GameAuthVerifier = async (token) => ({
  iss: 'test',
  aud: 'test',
  sub: token,
  iat: 1,
  exp: Number.MAX_SAFE_INTEGER,
});

const router = createGameRouter({
  verifyToken: verify,
  clock: () => new Date('2026-09-17T12:00:00.000Z'),
  randomBytes: () => new Uint8Array(32).fill(7),
});

beforeAll(async () => {
  await applyD1Migrations(testEnv.DB, testEnv.TEST_MIGRATIONS);
});

beforeEach(async () => {
  await testEnv.DB.exec(`
    DELETE FROM rate_limit_buckets;
    DELETE FROM active_session_slots;
    DELETE FROM global_records;
    DELETE FROM weekly_records;
    DELETE FROM accepted_results;
    DELETE FROM game_sessions;
    DELETE FROM public_players;
  `);
});

async function start(token = 'user-a') {
  const response = await router(
    new Request('https://test/v1/game/sessions', {
      method: 'POST',
      headers: { authorization: `Bearer ${token}` },
    }),
    testEnv,
  );
  expect(response.status).toBe(201);
  return response.json() as Promise<{
    sessionId: string;
    catalogVersion: string;
    round: { roundIndex: number; options: Array<{ id: number }> };
  }>;
}

describe('game routes', () => {
  it('completes the authenticated start, answer, and publish flow', async () => {
    const session = await start();
    const answerResponse = await answer(session.sessionId, {
      roundIndex: 0,
      optionId: 9999,
      token: 'user-a',
    });
    expect(answerResponse.status).toBe(200);
    await expect(answerResponse.json()).resolves.toMatchObject({ finished: true });

    const publish = await router(new Request(`https://test/v1/game/sessions/${session.sessionId}/publish`, {
      method: 'POST',
      headers: { authorization: 'Bearer user-a' },
    }), testEnv);
    expect(publish.status).toBe(200);
    await expect(publish.json()).resolves.toMatchObject({ state: 'published' });
  });

  it('rejects requests that exceed user, IP, body, and session caps', async () => {
    const limitedRouter = createGameRouter({
      verifyToken: verify,
      clock: () => new Date('2026-09-17T12:00:00.000Z'),
      randomBytes: (() => {
        let value = 7;
        return () => new Uint8Array(32).fill(value++);
      })(),
      limits: {
        sessionsPerWindow: 2,
        answersPerWindow: 10,
        publishesPerWindow: 10,
        maxActiveSessions: 2,
        maxAnswersPerSession: 1,
        maxPublishesPerSession: 1,
      },
    });
    const request = (token: string, ip: string) => limitedRouter(new Request(
      'https://test/v1/game/sessions',
      { method: 'POST', headers: { authorization: `Bearer ${token}`, 'cf-connecting-ip': ip } },
    ), testEnv);

    expect((await request('user-a', '203.0.113.10')).status).toBe(201);
    expect((await request('user-b', '203.0.113.10')).status).toBe(201);
    const ipLimited = await request('user-c', '203.0.113.10');
    expect(ipLimited.status).toBe(429);
    await expect(ipLimited.json()).resolves.toMatchObject({ error: { code: 'RATE_LIMITED' } });

    const bodyLimited = await limitedRouter(new Request('https://test/v1/game/sessions', {
      method: 'POST',
      headers: {
        authorization: 'Bearer user-d',
        'cf-connecting-ip': '203.0.113.11',
        'content-type': 'application/json',
        'content-length': '9000',
      },
      body: JSON.stringify({ value: 'x'.repeat(9000) }),
    }), testEnv);
    expect(bodyLimited.status).toBe(413);
    await expect(bodyLimited.json()).resolves.toMatchObject({ error: { code: 'REQUEST_BODY_TOO_LARGE' } });
  });

  it('rejects answers and publication attempts beyond per-session caps', async () => {
    let random = 30;
    const limitedRouter = createGameRouter({
      verifyToken: verify,
      clock: () => new Date('2026-09-17T12:00:00.000Z'),
      randomBytes: () => new Uint8Array(32).fill(random++),
      limits: { maxAnswersPerSession: 1, maxPublishesPerSession: 1 },
    });
    const sessionResponse = await limitedRouter(new Request('https://test/v1/game/sessions', {
      method: 'POST',
      headers: { authorization: 'Bearer capped-user', 'cf-connecting-ip': '203.0.113.20' },
    }), testEnv);
    const session = await sessionResponse.json() as { sessionId: string; round: { options: Array<{ id: number }> } };
    const target = await testEnv.DB.prepare('SELECT current_target_id AS id FROM game_sessions WHERE id = ?1')
      .bind(session.sessionId).first<{ id: number }>();
    const first = await limitedRouter(new Request(`https://test/v1/game/sessions/${session.sessionId}/answers`, {
      method: 'POST',
      headers: { authorization: 'Bearer capped-user', 'cf-connecting-ip': '203.0.113.20', 'content-type': 'application/json' },
      body: JSON.stringify({ roundIndex: 0, optionId: target!.id }),
    }), testEnv);
    expect(first.status).toBe(200);
    const cappedAnswer = await limitedRouter(new Request(`https://test/v1/game/sessions/${session.sessionId}/answers`, {
      method: 'POST',
      headers: { authorization: 'Bearer capped-user', 'cf-connecting-ip': '203.0.113.20', 'content-type': 'application/json' },
      body: JSON.stringify({ roundIndex: 1, optionId: 1 }),
    }), testEnv);
    expect(cappedAnswer.status).toBe(409);
    await expect(cappedAnswer.json()).resolves.toMatchObject({ error: { code: 'GAME_ANSWER_CAP' } });

    const finished = await limitedRouter(new Request(`https://test/v1/game/sessions/${session.sessionId}/answers`, {
      method: 'POST',
      headers: { authorization: 'Bearer capped-user', 'cf-connecting-ip': '203.0.113.21', 'content-type': 'application/json' },
      body: JSON.stringify({ roundIndex: 1, optionId: 9999 }),
    }), testEnv);
    expect(finished.status).toBe(409);

    const publishSession = await limitedRouter(new Request('https://test/v1/game/sessions', {
      method: 'POST',
      headers: { authorization: 'Bearer publish-user', 'cf-connecting-ip': '203.0.113.22' },
    }), testEnv).then((response) => response.json()) as { sessionId: string };
    await limitedRouter(new Request(`https://test/v1/game/sessions/${publishSession.sessionId}/answers`, {
      method: 'POST',
      headers: { authorization: 'Bearer publish-user', 'cf-connecting-ip': '203.0.113.22', 'content-type': 'application/json' },
      body: JSON.stringify({ roundIndex: 0, optionId: 9999 }),
    }), testEnv);
    const publish = (ip: string) => limitedRouter(new Request(
      `https://test/v1/game/sessions/${publishSession.sessionId}/publish`,
      { method: 'POST', headers: { authorization: 'Bearer publish-user', 'cf-connecting-ip': ip } },
    ), testEnv);
    expect((await publish('203.0.113.22')).status).toBe(200);
    const publishCap = await publish('203.0.113.23');
    expect(publishCap.status).toBe(200);
    await expect(publishCap.json()).resolves.toMatchObject({ state: 'published' });
  });

  it('enforces the active-session cap atomically for concurrent starts', async () => {
    let random = 60;
    const limitedRouter = createGameRouter({
      verifyToken: verify,
      clock: () => new Date('2026-09-17T12:00:00.000Z'),
      randomBytes: () => new Uint8Array(32).fill(random++),
      limits: { maxActiveSessions: 1 },
    });
    const request = () => limitedRouter(new Request('https://test/v1/game/sessions', {
      method: 'POST',
      headers: { authorization: 'Bearer concurrent-user', 'cf-connecting-ip': '203.0.113.30' },
    }), testEnv);

    const responses = await Promise.all([request(), request()]);
    expect(responses.map((response) => response.status).sort()).toEqual([201, 409]);
    await expect(responses.find((response) => response.status === 409)!.json())
      .resolves.toMatchObject({ error: { code: 'GAME_SESSION_CAP' } });
  });

  it('matches the shared public contract fixture without private answer fields', () => {
    expect(Object.keys(sharedContract.session)).toEqual([
      'sessionId',
      'catalogVersion',
      'round',
    ]);
    expect(Object.keys(sharedContract.answer)).toEqual([
      'sessionId',
      'roundIndex',
      'correct',
      'finished',
      'score',
      'correctPokemonName',
      'correctSpriteUrl',
      'nextRound',
    ]);
    for (const payload of [sharedContract.session.round, sharedContract.answer.nextRound]) {
      expect(Object.keys(payload as Record<string, unknown>)).toEqual([
        'roundIndex',
        'difficulty',
        'silhouetteUrl',
        'options',
      ]);
      for (const option of (payload as { options: Array<Record<string, unknown>> }).options) {
        expect(Object.keys(option)).toEqual(['id', 'slug', 'name', 'label', 'spriteUrl']);
        expect(option).not.toHaveProperty('isTarget');
        expect(option).not.toHaveProperty('correct_species_id');
        expect(option).not.toHaveProperty('correctSpeciesId');
      }
    }
  });

  it('requires authentication for session creation', async () => {
    const response = await router(new Request('https://test/v1/game/sessions', { method: 'POST' }), testEnv);
    expect(response.status).toBe(401);
    await expect(response.json()).resolves.toMatchObject({ error: { code: 'AUTH_REQUIRED' } });
  });

  it('starts an authenticated session with the current round', async () => {
    const result = await start();
    expect(result.sessionId).toMatch(/^[A-Za-z0-9_-]{43}$/);
    expect(result.catalogVersion).toBe('v1');
    expect(result.round).toMatchObject({ roundIndex: 0 });
    expect(result.round.options).toHaveLength(4);
  });

  it('rejects a forged answer and derives correctness from the server target', async () => {
    const session = await start();
    const response = await answer(session.sessionId, {
      roundIndex: 0,
      optionId: 9999,
      token: 'user-a',
    });
    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toMatchObject({
      correct: false,
      finished: true,
      score: 0,
    });
  });

  it('rejects replay and out-of-order answers', async () => {
    const session = await start();
    const first = session.round.options[0].id;
    const response = await answer(session.sessionId, {
      roundIndex: 1,
      optionId: first,
      token: 'user-a',
    });
    expect(response.status).toBe(409);
    await expect(response.json()).resolves.toMatchObject({ error: { code: 'GAME_ROUND_ORDER' } });
  });

  it('rejects replay after a correct answer', async () => {
    const session = await start();
    const target = await testEnv.DB.prepare('SELECT current_target_id AS id FROM game_sessions WHERE id = ?1')
      .bind(session.sessionId)
      .first<{ id: number }>();
    await answer(session.sessionId, { roundIndex: 0, optionId: target!.id, token: 'user-a' });
    const replay = await answer(session.sessionId, { roundIndex: 0, optionId: target!.id, token: 'user-a' });
    expect(replay.status).toBe(200);
    await expect(replay.json()).resolves.toMatchObject({ correct: true, score: 1 });
  });

  it('rejects a wrong owner without revealing session ownership', async () => {
    const session = await start();
    const response = await answer(session.sessionId, {
      roundIndex: 0,
      optionId: 1,
      token: 'user-b',
    });
    expect(response.status).toBe(404);
    await expect(response.json()).resolves.toMatchObject({ error: { code: 'GAME_SESSION_NOT_FOUND' } });
  });

  it('finishes on the first wrong answer', async () => {
    const session = await start();
    const target = session.round.options[0].id;
    const wrong = session.round.options.find((option) => option.id !== target)?.id ?? 9999;
    const response = await answer(session.sessionId, { roundIndex: 0, optionId: wrong, token: 'user-a' });
    await expect(response.json()).resolves.toMatchObject({ correct: false, finished: true, score: 0 });
  });

  it('returns the next deterministic round after a correct answer', async () => {
    const session = await start();
    const target = await testEnv.DB.prepare('SELECT current_target_id AS id FROM game_sessions WHERE id = ?1')
      .bind(session.sessionId)
      .first<{ id: number }>();
    const response = await answer(session.sessionId, { roundIndex: 0, optionId: target!.id, token: 'user-a' });
    await expect(response.json()).resolves.toMatchObject({
      correct: true,
      finished: false,
      score: 1,
      nextRound: { roundIndex: 1, options: expect.any(Array) },
    });
  });

  it('rejects malformed answer input', async () => {
    const session = await start();
    const response = await answer(session.sessionId, { roundIndex: '0', optionId: 1, token: 'user-a' });
    expect(response.status).toBe(400);
    await expect(response.json()).resolves.toMatchObject({ error: { code: 'GAME_INVALID_INPUT' } });
  });

  it('rejects answers after the ten-minute TTL', async () => {
    const session = await start();
    const expiredRouter = createGameRouter({
      verifyToken: verify,
      clock: () => new Date('2026-09-17T12:10:00.000Z'),
      randomBytes: () => new Uint8Array(32).fill(9),
    });
    const response = await expiredRouter(
      new Request(`https://test/v1/game/sessions/${session.sessionId}/answers`, {
        method: 'POST',
        headers: { authorization: 'Bearer user-a', 'content-type': 'application/json' },
        body: JSON.stringify({ roundIndex: 0, optionId: 1 }),
      }),
      testEnv,
    );
    expect(response.status).toBe(410);
    await expect(response.json()).resolves.toMatchObject({ error: { code: 'GAME_SESSION_EXPIRED' } });
  });

  it('retries a failed publication through the publish endpoint', async () => {
    const session = await start();
    const failingDb = {
      prepare: testEnv.DB.prepare.bind(testEnv.DB),
      exec: testEnv.DB.exec.bind(testEnv.DB),
      batch: async (statements: Parameters<typeof testEnv.DB.batch>[0]) => {
        if (statements.length === 3) throw new Error('publication unavailable');
        return testEnv.DB.batch(statements);
      },
    };
    const failed = await router(
      new Request(`https://test/v1/game/sessions/${session.sessionId}/answers`, {
        method: 'POST',
        headers: { authorization: 'Bearer user-a', 'content-type': 'application/json' },
        body: JSON.stringify({ roundIndex: 0, optionId: 9999 }),
      }),
      { ...testEnv, DB: failingDb } as never,
    );
    expect(failed.status).toBe(200);
    await expect(failed.json()).resolves.toMatchObject({ finished: true, score: 0 });

    const retried = await router(
      new Request(`https://test/v1/game/sessions/${session.sessionId}/publish`, {
        method: 'POST',
        headers: { authorization: 'Bearer user-a' },
      }),
      testEnv,
    );
    expect(retried.status).toBe(200);
    await expect(retried.json()).resolves.toMatchObject({ state: 'published' });

    const repeated = await router(
      new Request(`https://test/v1/game/sessions/${session.sessionId}/publish`, {
        method: 'POST',
        headers: { authorization: 'Bearer user-a' },
      }),
      testEnv,
    );
    expect(repeated.status).toBe(200);
    await expect(repeated.json()).resolves.toMatchObject({ state: 'published' });
    expect((await testEnv.DB.prepare('SELECT COUNT(*) AS count FROM accepted_results').first<{ count: number }>())?.count).toBe(1);
  });
});

async function answer(sessionId: string, input: Record<string, unknown>) {
  const { token = 'user-a', ...body } = input;
  return router(
    new Request(`https://test/v1/game/sessions/${sessionId}/answers`, {
      method: 'POST',
      headers: { authorization: `Bearer ${token}`, 'content-type': 'application/json' },
      body: JSON.stringify(body),
    }),
    testEnv,
  );
}
