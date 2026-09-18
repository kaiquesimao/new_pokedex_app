import { verifyFirebaseIdToken, type FirebaseClaims, type FirebaseAuthEnv } from '../auth';
import { getLeaderboard, type Clock, type D1Binding } from '../db';
import { encodeCursor, getBearerToken, HttpError, jsonError, parsePagination, parseScope } from '../http';

export interface LeaderboardAuthVerifier {
  (token: string, env: FirebaseAuthEnv): Promise<FirebaseClaims>;
}

interface LeaderboardEnv extends FirebaseAuthEnv {
  DB: D1Binding;
  CURSOR_ENCRYPTION_KEY: string;
}

export function createLeaderboardRouter(options: {
  verifyToken?: LeaderboardAuthVerifier;
  clock?: Clock;
} = {}) {
  const verifyToken = options.verifyToken ?? verifyFirebaseIdToken;
  return async (request: Request, env: LeaderboardEnv): Promise<Response> => {
    try {
      const authorization = request.headers.get('authorization');
      const claims = authorization ? await verifyToken(getBearerToken(request), env) : null;
      const url = new URL(request.url);
      if (request.method !== 'GET') return jsonError(new HttpError('METHOD_NOT_ALLOWED', 'Method is not allowed', 405));
      const scope = parseScope(url.searchParams.get('scope'));
      const cursorOptions = {
        encryptionKey: env.CURSOR_ENCRYPTION_KEY,
        scope,
        now: options.clock?.() ?? new Date(),
      };
      const pagination = await parsePagination(url, cursorOptions);
      const entries = await getLeaderboard(env.DB, {
        scope,
        weekKey: scope === 'weekly' ? utcWeekKey(new Date()) : undefined,
        limit: pagination.limit,
        cursor: pagination.cursor,
        currentUserId: claims?.sub,
        includeCursorUserId: true,
      });
      const next = entries.length === pagination.limit ? entries.at(-1) : undefined;
      return Response.json({
        entries: entries.map(({ avatarUrl: _, anonymous, userId: __, displayName, score, achievedAt, rank, isCurrentUser }) => ({
          rank,
          score,
          player_name: displayName,
          completed_at: achievedAt,
          is_anonymous: anonymous,
          is_current_user: isCurrentUser ?? false,
        })),
        next_cursor: next?.userId ? await encodeCursor({ score: next.score, achievedAt: next.achievedAt, userId: next.userId }, cursorOptions) : null,
      });
    } catch (error) {
      return jsonError(error);
    }
  };
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
