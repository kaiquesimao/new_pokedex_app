import { applyD1Migrations } from 'cloudflare:test';
import { env } from 'cloudflare:workers';
import { beforeAll, beforeEach, describe, expect, it } from 'vitest';

import { createLeaderboardRouter } from '../src/routes/leaderboards';
import { createProfileRouter } from '../src/routes/profile';
import { createSession, saveAcceptedResult, upsertPublicProfile, type D1Binding } from '../src/db';

const testEnv = env as typeof env & {
  DB: D1Database;
  TEST_MIGRATIONS: Parameters<typeof applyD1Migrations>[1];
  FIREBASE_PROJECT_ID: string;
  CURSOR_ENCRYPTION_KEY: string;
};

const cursorKey = btoa(String.fromCharCode(...new Uint8Array(32).fill(7)))
  .replaceAll('+', '-').replaceAll('/', '_').replace(/=+$/, '');

const verify = async (token: string) => ({
  iss: 'test',
  aud: 'test',
  sub: token,
  iat: 1,
  exp: Number.MAX_SAFE_INTEGER,
});

const leaderboardRouter = createLeaderboardRouter({
  verifyToken: verify,
  clock: () => new Date('2026-09-17T12:00:00.000Z'),
});
const profileRouter = createProfileRouter({ verifyToken: verify });

beforeAll(async () => {
  testEnv.CURSOR_ENCRYPTION_KEY = cursorKey;
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

describe('Task 5 profile routes', () => {
  it('rejects guests and projects an authenticated profile without its UID', async () => {
    const guest = await profileRouter(new Request('https://test/v1/me/game-profile'), testEnv);
    expect(guest.status).toBe(401);

    const response = await profileRouter(new Request('https://test/v1/me/game-profile', {
      headers: { authorization: 'Bearer user-a' },
    }), testEnv);
    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({
      isAnonymous: true,
      displayName: 'Treinador anonimo',
    });
  });

  it('updates the authenticated projection and rejects malformed profile input', async () => {
    const response = await profileRouter(new Request('https://test/v1/me/game-profile', {
      method: 'PATCH',
      headers: { authorization: 'Bearer user-a', 'content-type': 'application/json' },
      body: JSON.stringify({ isAnonymous: false, displayName: 'Ash' }),
    }), testEnv);
    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({ isAnonymous: false, displayName: 'Ash' });

    const invalid = await profileRouter(new Request('https://test/v1/me/game-profile', {
      method: 'PATCH',
      headers: { authorization: 'Bearer user-a', 'content-type': 'application/json' },
      body: JSON.stringify({ isAnonymous: 'no' }),
    }), testEnv);
    expect(invalid.status).toBe(400);
  });
});

describe('Task 5 leaderboard route', () => {
  it('returns scoped ties, absolute ranks, opaque pagination, anonymous names, and current user', async () => {
    await seedResult(testEnv.DB, 'user-a', 'a', 10, '2026-09-17T12:00:00.000Z', false, 'Ash');
    await seedResult(testEnv.DB, 'user-b', 'b', 10, '2026-09-17T12:01:00.000Z', true);
    await seedResult(testEnv.DB, 'user-c', 'c', 5, '2026-09-17T12:02:00.000Z', false, 'Misty');

    const first = await leaderboardRouter(new Request('https://test/v1/leaderboards?scope=weekly&limit=2', {
      headers: { authorization: 'Bearer user-b' },
    }), testEnv);
    expect(first.status).toBe(200);
    const firstBody = await first.json() as { entries: unknown[]; next_cursor: string };
    expect(firstBody.entries).toEqual([
      { rank: 1, score: 10, completed_at: '2026-09-17T12:00:00.000Z', player_name: 'Ash', is_anonymous: false, is_current_user: false },
      { rank: 2, score: 10, completed_at: '2026-09-17T12:01:00.000Z', player_name: 'Treinador anonimo', is_anonymous: true, is_current_user: true },
    ]);
    expect(firstBody.next_cursor).toEqual(expect.any(String));

    const second = await leaderboardRouter(new Request(`https://test/v1/leaderboards?scope=weekly&limit=2&cursor=${firstBody.next_cursor}`, {
      headers: { authorization: 'Bearer user-b' },
    }), testEnv);
    await expect(second.json()).resolves.toMatchObject({
      entries: [{ rank: 3, score: 5, player_name: 'Misty', is_current_user: false }],
      next_cursor: null,
    });
  });

  it('supports global scope for guests and rejects invalid scopes', async () => {
    await seedResult(testEnv.DB, 'user-a', 'a', 1, '2026-09-17T12:00:00.000Z', false, 'Ash');
    await seedResult(testEnv.DB, 'user-b', 'b', 1, '2026-09-17T12:01:00.000Z', false, 'Misty');
    const guest = await leaderboardRouter(new Request('https://test/v1/leaderboards?scope=global&limit=1'), testEnv);
    expect(guest.status).toBe(200);
    const guestBody = await guest.json() as { entries: Array<Record<string, unknown>>; next_cursor: string | null };
    expect(guestBody.entries[0]).not.toHaveProperty('user_id');
    expect(guestBody.entries[0]).not.toHaveProperty('userId');
    expect(guestBody.next_cursor).toEqual(expect.any(String));
    expect(guestBody.next_cursor).not.toContain('user-');
    const secondPage = await leaderboardRouter(new Request(
      `https://test/v1/leaderboards?scope=global&limit=1&cursor=${guestBody.next_cursor}`,
    ), testEnv);
    expect(secondPage.status).toBe(200);
    await expect(secondPage.json()).resolves.toMatchObject({
      entries: [{ player_name: 'Misty' }],
      next_cursor: expect.any(String),
    });
    const invalid = await leaderboardRouter(new Request('https://test/v1/leaderboards?scope=all', {
      headers: { authorization: 'Bearer user-a' },
    }), testEnv);
    expect(invalid.status).toBe(400);
    const global = await leaderboardRouter(new Request('https://test/v1/leaderboards?scope=global&limit=1', {
      headers: { authorization: 'Bearer user-a' },
    }), testEnv);
    await expect(global.json()).resolves.toMatchObject({ entries: [{ rank: 1 }] });
  });
});

async function seedResult(
  db: D1Binding,
  userId: string,
  sessionId: string,
  score: number,
  achievedAt: string,
  anonymous: boolean,
  displayName: string | null = null,
) {
  await upsertPublicProfile(db, { userId, displayName, avatarUrl: null, anonymous });
  await createSession(db, { id: sessionId, userId, currentTargetId: 25, now: '2026-09-17T11:00:00.000Z', expiresAt: '2026-09-17T13:00:00.000Z' });
  await db.prepare("UPDATE game_sessions SET state = 'completed', score = ?1 WHERE id = ?2").bind(score, sessionId).run();
  await saveAcceptedResult(db, { userId, sessionId }, () => new Date(achievedAt));
}
