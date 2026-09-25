import { Hono } from 'hono';

import { verifyFirebaseIdToken, type FirebaseAuthEnv } from '../auth';
import { getLeaderboard, type Clock, type D1Binding } from '../db';
import { optionalAuth, type AuthVerifier, type OptionalAuthVariables } from '../middleware/auth';
import { handleError, handleNotFound } from '../middleware/errors';
import { encodeCursor, HttpError, parsePagination, parseScope } from '../http';

export type LeaderboardAuthVerifier = AuthVerifier;

type LeaderboardBindings = FirebaseAuthEnv & {
  DB: D1Binding;
  CURSOR_ENCRYPTION_KEY: string;
};

type LeaderboardEnv = {
  Bindings: LeaderboardBindings;
  Variables: OptionalAuthVariables;
};

/** Leaderboard routes mounted at `/v1/leaderboards`. */
export function createLeaderboardApp(options: {
  verifyToken?: LeaderboardAuthVerifier;
  clock?: Clock;
} = {}) {
  const verifyToken = options.verifyToken ?? verifyFirebaseIdToken;
  const app = new Hono<LeaderboardEnv>();

  app.onError(handleError);
  app.notFound(handleNotFound);
  app.use('*', optionalAuth(verifyToken));

  app.get('/', async (c) => {
    const url = new URL(c.req.url);
    const scope = parseScope(url.searchParams.get('scope'));
    const cursorOptions = {
      encryptionKey: c.env.CURSOR_ENCRYPTION_KEY,
      scope,
      now: options.clock?.() ?? new Date(),
    };
    const pagination = await parsePagination(url, cursorOptions);
    const claims = c.get('claims');
    const entries = await getLeaderboard(c.env.DB, {
      scope,
      weekKey: scope === 'weekly'
        ? utcWeekKey(options.clock?.() ?? new Date())
        : undefined,
      limit: pagination.limit,
      cursor: pagination.cursor,
      currentUserId: claims?.sub,
      includeCursorUserId: true,
    });
    const next = entries.length === pagination.limit ? entries.at(-1) : undefined;
    return c.json({
      entries: entries.map(({
        avatarUrl: _,
        anonymous,
        userId: __,
        displayName,
        score,
        achievedAt,
        rank,
        isCurrentUser,
      }) => ({
        rank,
        score,
        player_name: displayName,
        completed_at: achievedAt,
        is_anonymous: anonymous,
        is_current_user: isCurrentUser ?? false,
      })),
      next_cursor: next?.userId
        ? await encodeCursor(
          { score: next.score, achievedAt: next.achievedAt, userId: next.userId },
          cursorOptions,
        )
        : null,
    });
  });

  app.all('/', () => {
    throw new HttpError('METHOD_NOT_ALLOWED', 'Method is not allowed', 405);
  });

  return app;
}

/** Fetch-compatible adapter for unit tests that call `(request, env)`. */
export function createLeaderboardRouter(options: {
  verifyToken?: LeaderboardAuthVerifier;
  clock?: Clock;
} = {}) {
  const app = new Hono<{ Bindings: LeaderboardBindings }>();
  app.onError(handleError);
  app.notFound(handleNotFound);
  app.route('/v1/leaderboards', createLeaderboardApp(options));
  return async (request: Request, env: LeaderboardBindings): Promise<Response> =>
    app.fetch(request, env);
}

function utcWeekKey(value: Date): string {
  const date = new Date(value.getTime());
  date.setUTCHours(0, 0, 0, 0);
  const day = date.getUTCDay() || 7;
  date.setUTCDate(date.getUTCDate() + 4 - day);
  const year = date.getUTCFullYear();
  const firstThursday = new Date(Date.UTC(year, 0, 4));
  const firstDay = firstThursday.getUTCDay() || 7;
  const week = 1 + Math.round(((date.getTime() - firstThursday.getTime()) / 86400000 - 3 + firstDay) / 7);
  return `${year}-W${String(week).padStart(2, '0')}`;
}

export const leaderboardRouter = createLeaderboardRouter();
