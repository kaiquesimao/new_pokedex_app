import { Hono } from 'hono';

import { verifyFirebaseIdToken, type FirebaseAuthEnv } from '../auth';
import { saveAcceptedResult, type D1Binding } from '../db';
import { abuseLimits, answerGameSession, startGameSession, type GameServiceOptions } from '../game_service';
import { requireAuth, type AuthVerifier, type AuthVariables } from '../middleware/auth';
import { requireEmptyBody } from '../middleware/body';
import { handleError, handleNotFound } from '../middleware/errors';
import { enforceRateLimit } from '../rate_limit';
import { HttpError, parseJsonBody } from '../http';

export type GameAuthVerifier = AuthVerifier;

export interface GameRouteOptions extends GameServiceOptions {
  verifyToken?: GameAuthVerifier;
}

type GameBindings = FirebaseAuthEnv & { DB: D1Binding };
type GameEnv = { Bindings: GameBindings; Variables: AuthVariables };

const SESSION_ID = ':sessionId{[A-Za-z0-9_-]{43}}';

/** Game routes under `/v1/game` (relative paths for Hono `route` mounting). */
export function createGameApp(options: GameRouteOptions = {}) {
  const verifyToken = options.verifyToken ?? verifyFirebaseIdToken;
  const app = new Hono<GameEnv>();

  app.onError(handleError);
  app.notFound(handleNotFound);
  app.use('*', requireAuth(verifyToken));

  app.post('/sessions', requireEmptyBody(), async (c) => {
    const userId = c.get('userId');
    await enforceRateLimit(
      c.env.DB,
      'session',
      userId,
      requestIp(c.req.raw),
      abuseLimits(options),
      options.clock ?? (() => new Date()),
    );
    return c.json(await startGameSession(c.env.DB, userId, options), 201);
  });

  app.post(`/sessions/${SESSION_ID}/answers`, async (c) => {
    const userId = c.get('userId');
    const sessionId = c.req.param('sessionId');
    await enforceRateLimit(
      c.env.DB,
      'answer',
      userId,
      requestIp(c.req.raw),
      abuseLimits(options),
      options.clock ?? (() => new Date()),
    );
    const body = await parseJsonBody(c.req.raw);
    const roundIndex = parseInteger(body.roundIndex);
    const optionId = parseInteger(body.optionId);
    const result = await answerGameSession(
      c.env.DB,
      sessionId,
      userId,
      roundIndex,
      optionId,
      options,
    );
    if (result.finished) {
      try {
        await saveAcceptedResult(c.env.DB, { userId, sessionId }, options.clock);
      } catch {
        // Completion is already validated and persisted; publish can be retried.
      }
    }
    return c.json(result);
  });

  app.post(`/sessions/${SESSION_ID}/publish`, requireEmptyBody(), async (c) => {
    const userId = c.get('userId');
    const sessionId = c.req.param('sessionId');
    await enforceRateLimit(
      c.env.DB,
      'publish',
      userId,
      requestIp(c.req.raw),
      abuseLimits(options),
      options.clock ?? (() => new Date()),
    );
    const existing = await c.env.DB.prepare(`
       SELECT publish_count FROM game_sessions WHERE id = ?1 AND user_id = ?2
     `).bind(sessionId, userId).first<{ publish_count: number }>();
    if (!existing) throw new HttpError('GAME_SESSION_NOT_FOUND', 'Game session was not found', 404);
    const alreadyPublished = await c.env.DB.prepare(
      'SELECT achieved_at FROM accepted_results WHERE session_id = ?1 AND user_id = ?2',
    ).bind(sessionId, userId).first<{ achieved_at: string }>();
    if (alreadyPublished) {
      return c.json({ state: 'published', published_at: alreadyPublished.achieved_at });
    }
    const [claimed] = await c.env.DB.batch([c.env.DB.prepare(`
      UPDATE game_sessions
      SET publish_count = publish_count + 1
      WHERE id = ?1 AND user_id = ?2 AND publish_count < ?3
    `).bind(sessionId, userId, abuseLimits(options).maxPublishesPerSession)]);
    if (claimed.meta.changes !== 1) {
      throw new HttpError('GAME_PUBLISH_CAP', 'Game publication limit reached', 409);
    }
    const publication = await saveAcceptedResult(
      c.env.DB,
      { userId, sessionId },
      options.clock,
    );
    return c.json({ state: 'published', published_at: publication.publishedAt });
  });

  return app;
}

/** Fetch-compatible adapter for unit tests that call `(request, env)`. */
export function createGameRouter(options: GameRouteOptions = {}) {
  const app = new Hono<{ Bindings: GameBindings }>();
  app.onError(handleError);
  app.notFound(handleNotFound);
  app.route('/v1/game', createGameApp(options));
  return async (request: Request, env: GameBindings): Promise<Response> =>
    app.fetch(request, env);
}

function parseInteger(value: unknown): number {
  if (!Number.isSafeInteger(value) || (value as number) < 0) {
    throw new HttpError('GAME_INVALID_INPUT', 'Invalid game input', 400);
  }
  return value as number;
}

function requestIp(request: Request): string {
  const value = request.headers.get('cf-connecting-ip')?.trim();
  return value && value.length <= 64 ? value : 'unknown';
}

export const gameRouter = createGameRouter();
