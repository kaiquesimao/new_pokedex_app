import { applyD1Migrations } from 'cloudflare:test';
import { env } from 'cloudflare:workers';
import { beforeAll, beforeEach, describe, expect, it } from 'vitest';

import {
  createSession,
  completeSession,
  canonicalUtcTimestamp,
  advanceSessionTarget,
  type Clock,
  getLeaderboard,
  getSession,
  recordAnswer,
  saveAcceptedResult,
  upsertPublicProfile,
} from '../src/db';

const testEnv = env as typeof env & {
  DB: D1Database;
  TEST_MIGRATIONS: Parameters<typeof applyD1Migrations>[1];
};
const db = testEnv.DB;
const userA = 'internal-user-a';
const userB = 'internal-user-b';
const clockAt = (value: string): Clock => () => new Date(value);

beforeAll(async () => {
  await applyD1Migrations(db, testEnv.TEST_MIGRATIONS);
});

beforeEach(async () => {
  await db.exec(`
    DELETE FROM active_session_slots;
    DELETE FROM global_records;
    DELETE FROM weekly_records;
    DELETE FROM accepted_results;
    DELETE FROM game_sessions;
    DELETE FROM public_players;
  `);
});

describe('sessions', () => {
  it('creates and reads an active session without exposing implementation details', async () => {
    const session = await createSession(db, {
      id: 'session-a',
      userId: userA,
      currentTargetId: 25,
      now: '2026-09-17T12:00:00.000Z',
      expiresAt: '2026-09-17T12:10:00.000Z',
    });

    expect(session).toEqual({
      id: 'session-a',
      state: 'active',
      score: 0,
      currentRound: 0,
      startedAt: '2026-09-17T12:00:00.000Z',
      expiresAt: '2026-09-17T12:10:00.000Z',
      completedAt: null,
    });
    expect(await getSession(db, 'session-a', userA, clockAt('2026-09-17T12:05:00.000Z'))).toEqual(session);
  });

  it('derives correctness from the stored target and rejects forged target answers', async () => {
    await createSession(db, {
      id: 'session-answer',
      userId: userA,
      currentTargetId: 25,
      now: '2026-09-17T12:00:00.000Z',
      expiresAt: '2026-09-17T12:10:00.000Z',
    });

    await expect(recordAnswer(db, {
      sessionId: 'session-answer',
      expectedRound: 1,
      answerPokemonId: 25,
    }, clockAt('2026-09-17T12:01:00.000Z'), { userId: userA })).rejects.toThrow('Unexpected round');
    expect(await recordAnswer(db, {
      sessionId: 'session-answer',
      expectedRound: 0,
      answerPokemonId: 24,
      isCorrect: true,
      points: 999,
      correctPokemonId: 25,
      currentTargetId: 25,
    } as never, clockAt('2026-09-17T12:01:00.000Z'), { userId: userA })).toMatchObject({ score: 0, currentRound: 1 });
    expect(await recordAnswer(db, {
      sessionId: 'session-answer',
      expectedRound: 1,
      answerPokemonId: 25,
    }, clockAt('2026-09-17T12:01:00.000Z'), { userId: userA })).toMatchObject({ score: 1, currentRound: 2 });
    expect((await db.prepare('SELECT current_target_id AS target FROM game_sessions WHERE id = ?1').bind('session-answer').first<{ target: number }>())?.target).toBe(25);
    await advanceSessionTarget(db, { sessionId: 'session-answer', userId: userA, expectedRound: 2, nextTargetId: 133 }, clockAt('2026-09-17T12:01:00.000Z'));
    expect((await db.prepare('SELECT current_target_id AS target FROM game_sessions WHERE id = ?1').bind('session-answer').first<{ target: number }>())?.target).toBe(133);
    await expect(advanceSessionTarget(db, { sessionId: 'session-answer', userId: userA, expectedRound: 2, nextTargetId: 7 }, clockAt('2026-09-17T12:01:00.000Z'))).rejects.toThrow('Session target could not be advanced');
  });

  it('reports an expired session at the exact expiry and refuses answers after expiry', async () => {
    await createSession(db, {
      id: 'session-expired',
      userId: userA,
      currentTargetId: 25,
      now: '2026-09-17T12:00:00.000Z',
      expiresAt: '2026-09-17T12:10:00.000Z',
    });

    expect(await getSession(db, 'session-expired', userA, clockAt('2026-09-17T12:10:00.000Z'))).toMatchObject({
      state: 'expired',
    });
    await expect(recordAnswer(db, {
      sessionId: 'session-expired',
      expectedRound: 0,
      answerPokemonId: 25,
    }, clockAt('2026-09-17T12:10:00.000Z'), { userId: userA })).rejects.toThrow('Session is not active');
  });

  it('rejects wrong owners and completed sessions', async () => {
    await createSession(db, {
      id: 'session-owner',
      userId: userA,
      currentTargetId: 25,
      now: '2026-09-17T12:00:00.000Z',
      expiresAt: '2026-09-17T12:10:00.000Z',
    });
    await expect(recordAnswer(db, {
      sessionId: 'session-owner',
      expectedRound: 0,
      answerPokemonId: 25,
    }, clockAt('2026-09-17T12:01:00.000Z'), { userId: userB })).rejects.toThrow('Session was not found');
    await completeSession(db, 'session-owner', userA, clockAt('2026-09-17T12:02:00.000Z'));
    await expect(recordAnswer(db, {
      sessionId: 'session-owner',
      expectedRound: 0,
      answerPokemonId: 25,
    }, clockAt('2026-09-17T12:03:00.000Z'), { userId: userA })).rejects.toThrow('Session is not active');
  });

  it('only advances a valid server target after a correct answer', async () => {
    await createSession(db, { id: 'session-wrong', userId: userA, currentTargetId: 25, now: '2026-09-17T12:00:00.000Z', expiresAt: '2026-09-17T12:10:00.000Z' });
    await recordAnswer(db, { sessionId: 'session-wrong', expectedRound: 0, answerPokemonId: 24 }, clockAt('2026-09-17T12:01:00.000Z'), { userId: userA });
    await expect(advanceSessionTarget(db, { sessionId: 'session-wrong', userId: userA, expectedRound: 1, nextTargetId: 133 }, clockAt('2026-09-17T12:01:00.000Z'))).rejects.toThrow('Session target could not be advanced');
    await expect(advanceSessionTarget(db, { sessionId: 'session-wrong', userId: userA, expectedRound: 1, nextTargetId: 0 }, clockAt('2026-09-17T12:01:00.000Z'))).rejects.toThrow('Invalid next target ID');
    await expect(advanceSessionTarget(db, { sessionId: 'session-wrong', userId: userA, expectedRound: 1, nextTargetId: 'forged' as never }, clockAt('2026-09-17T12:01:00.000Z'))).rejects.toThrow('Invalid next target ID');

    await createSession(db, { id: 'session-complete-target', userId: userA, currentTargetId: 25, now: '2026-09-17T12:00:00.000Z', expiresAt: '2026-09-17T12:10:00.000Z' });
    await recordAnswer(db, { sessionId: 'session-complete-target', expectedRound: 0, answerPokemonId: 25 }, clockAt('2026-09-17T12:01:00.000Z'), { userId: userA });
    await completeSession(db, 'session-complete-target', userA, clockAt('2026-09-17T12:02:00.000Z'));
    await expect(advanceSessionTarget(db, { sessionId: 'session-complete-target', userId: userA, expectedRound: 1, nextTargetId: 133 }, clockAt('2026-09-17T12:03:00.000Z'))).rejects.toThrow('Session target could not be advanced');

    await createSession(db, { id: 'session-expired-target', userId: userA, currentTargetId: 25, now: '2026-09-17T12:00:00.000Z', expiresAt: '2026-09-17T12:10:00.000Z' });
    await recordAnswer(db, { sessionId: 'session-expired-target', expectedRound: 0, answerPokemonId: 25 }, clockAt('2026-09-17T12:09:00.000Z'), { userId: userA });
    await expect(advanceSessionTarget(db, { sessionId: 'session-expired-target', userId: userA, expectedRound: 1, nextTargetId: 133 }, clockAt('2026-09-17T12:10:00.000Z'))).rejects.toThrow('Session target could not be advanced');
  });

  it('rejects malformed timestamps and exposes canonical UTC timestamps', async () => {
    expect(canonicalUtcTimestamp('2026-09-17T12:00:00.000Z')).toBe('2026-09-17T12:00:00.000Z');
    expect(() => canonicalUtcTimestamp('2026-09-17 12:00:00')).toThrow('Invalid UTC timestamp');
    expect(() => canonicalUtcTimestamp('2026-02-30T12:00:00.000Z')).toThrow('Invalid UTC timestamp');
    await expect(createSession(db, {
      id: 'missing-target',
      userId: userA,
      currentTargetId: undefined as never,
      now: '2026-09-17T12:00:00.000Z',
      expiresAt: '2026-09-17T12:10:00.000Z',
    })).rejects.toThrow('Invalid current target ID');
  });
});

describe('results and leaderboard', () => {
  it('keeps one best result per user and scope and orders score then achievement time', async () => {
    await upsertPublicProfile(db, { userId: userA, displayName: 'Ash', avatarUrl: null, anonymous: false });
    await upsertPublicProfile(db, { userId: userB, displayName: null, avatarUrl: null, anonymous: true });

    await createCompletedSession('session-a', userA, 1, '2026-09-17T12:00:00.000Z');
    await saveAcceptedResult(db, {
      userId: userA,
      sessionId: 'session-a',
    }, clockAt('2026-09-17T12:00:00.000Z'));
    await createCompletedSession('session-a-2', userA, 2, '2026-09-17T12:00:30.000Z');
    await saveAcceptedResult(db, {
      userId: userA,
      sessionId: 'session-a-2',
    }, clockAt('2026-09-17T12:01:00.000Z'));
    await expect(saveAcceptedResult(db, {
      userId: userB,
      sessionId: 'session-a',
    }, clockAt('2026-09-17T12:02:00.000Z'))).rejects.toThrow('Session does not belong to user');

    await createCompletedSession('session-b', userB, 2, '2026-09-17T12:00:45.000Z');
    await saveAcceptedResult(db, {
      userId: userB,
      sessionId: 'session-b',
    }, clockAt('2026-09-17T12:01:00.000Z'));

    expect(await getLeaderboard(db, { scope: 'weekly', weekKey: '2026-W38' })).toEqual([
      { rank: 1, score: 2, achievedAt: '2026-09-17T12:01:00.000Z', displayName: 'Ash', avatarUrl: null, anonymous: false },
      { rank: 2, score: 2, achievedAt: '2026-09-17T12:01:00.000Z', displayName: 'Treinador anonimo', avatarUrl: null, anonymous: true },
    ]);
    expect(await getLeaderboard(db, {
      scope: 'weekly',
      weekKey: '2026-W38',
      cursor: { score: 2, achievedAt: '2026-09-17T12:01:00.000Z', userId: userA },
    })).toEqual([{ rank: 2, score: 2, achievedAt: '2026-09-17T12:01:00.000Z', displayName: 'Treinador anonimo', avatarUrl: null, anonymous: true }]);
    expect(await getLeaderboard(db, { scope: 'global' })).toHaveLength(2);
  });

  it('preserves a lower score and uses earlier achieved time for equal-score ties', async () => {
    await createCompletedSession('session-one', userA, 10, '2026-09-17T12:00:00.000Z');
    await saveAcceptedResult(db, { userId: userA, sessionId: 'session-one' }, clockAt('2026-09-17T12:05:00.000Z'));
    await createCompletedSession('session-two', userA, 8, '2026-09-17T12:01:00.000Z');
    await saveAcceptedResult(db, { userId: userA, sessionId: 'session-two' }, clockAt('2026-09-17T12:01:00.000Z'));
    expect((await getLeaderboard(db, { scope: 'weekly', weekKey: '2026-W38' }))[0]).toMatchObject({ score: 10, achievedAt: '2026-09-17T12:05:00.000Z' });
  });

  it('rejects an invalid scope instead of interpolating it into SQL', async () => {
    await expect(getLeaderboard(db, { scope: 'global; DROP TABLE public_players' as 'global' })).rejects.toThrow('Invalid leaderboard scope');
  });

  it('requires a completed owned session and its stored score', async () => {
    await createSession(db, { id: 'session-active', userId: userA, currentTargetId: 25, now: '2026-09-17T12:00:00.000Z', expiresAt: '2026-09-17T12:10:00.000Z' });
    await expect(saveAcceptedResult(db, { userId: userA, sessionId: 'session-active' }, clockAt('2026-09-17T12:01:00.000Z'))).rejects.toThrow('Session is not completed');
    await expect(saveAcceptedResult(db, { userId: userA, sessionId: 'missing' }, clockAt('2026-09-17T12:01:00.000Z'))).rejects.toThrow('Session was not found');
    await createCompletedSession('session-score', userA, 1, '2026-09-17T12:02:00.000Z');
    await saveAcceptedResult(db, { userId: userA, sessionId: 'session-score' }, clockAt('2026-09-17T12:03:00.000Z'));
  });

  it('rejects publication time before session start and ignores forged time/week fields', async () => {
    await createCompletedSession('session-time', userA, 1, '2026-09-17T12:00:00.000Z');
    await expect(saveAcceptedResult(db, { userId: userA, sessionId: 'session-time' }, clockAt('2026-09-17T11:59:59.000Z'))).rejects.toThrow('Timestamp precedes session start');
    await saveAcceptedResult(db, {
      userId: userA,
      sessionId: 'session-time',
      achievedAt: '2000-01-01T00:00:00.000Z',
      weekKey: '1999-W01',
    } as never, clockAt('2026-09-17T12:01:00.000Z'));
    expect(await getLeaderboard(db, { scope: 'weekly', weekKey: '2026-W38' })).toHaveLength(1);
    expect(await getLeaderboard(db, { scope: 'weekly', weekKey: '1999-W01' })).toHaveLength(0);
  });

  it('rolls back accepted result and records when one publication statement fails', async () => {
    await createCompletedSession('session-atomic', userA, 1, '2026-09-17T12:00:00.000Z');
    const failingDb = {
      ...db,
      prepare: db.prepare.bind(db),
      exec: db.exec.bind(db),
      batch: (statements: Parameters<typeof db.batch>[0]) => db.batch([
        ...statements,
        db.prepare('INSERT INTO missing_publication_table VALUES (1)'),
      ]),
    };
    await expect(saveAcceptedResult(failingDb, { userId: userA, sessionId: 'session-atomic' }, clockAt('2026-09-17T12:01:00.000Z'))).rejects.toThrow();
    expect((await db.prepare('SELECT COUNT(*) AS count FROM accepted_results').first<{ count: number }>())?.count).toBe(0);
    expect((await db.prepare('SELECT COUNT(*) AS count FROM weekly_records').first<{ count: number }>())?.count).toBe(0);
    expect((await db.prepare('SELECT COUNT(*) AS count FROM global_records').first<{ count: number }>())?.count).toBe(0);
  });

  it('publishes a completed session idempotently', async () => {
    await createCompletedSession('session-idempotent', userA, 3, '2026-09-17T12:00:00.000Z');
    await saveAcceptedResult(db, { userId: userA, sessionId: 'session-idempotent' }, clockAt('2026-09-17T12:01:00.000Z'));
    await saveAcceptedResult(db, { userId: userA, sessionId: 'session-idempotent' }, clockAt('2026-09-17T12:02:00.000Z'));

    expect((await db.prepare('SELECT COUNT(*) AS count FROM accepted_results').first<{ count: number }>())?.count).toBe(1);
    expect((await db.prepare('SELECT COUNT(*) AS count FROM weekly_records').first<{ count: number }>())?.count).toBe(1);
    expect((await db.prepare('SELECT COUNT(*) AS count FROM global_records').first<{ count: number }>())?.count).toBe(1);
  });
});

async function createCompletedSession(id: string, userId: string, score: number, now: string) {
  await createSession(db, { id, userId, currentTargetId: 25, now, expiresAt: '2026-09-17T12:10:00.000Z' });
  if (score > 0) {
    for (let round = 0; round < score; round += 1) {
      await recordAnswer(db, { sessionId: id, expectedRound: round, answerPokemonId: 25 }, clockAt(now), { userId });
    }
  }
  await completeSession(db, id, userId, clockAt('2026-09-17T12:09:00.000Z'));
}
