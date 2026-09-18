import { verifyFirebaseIdToken, type FirebaseClaims, type FirebaseAuthEnv } from '../auth';
import { saveAcceptedResult, type D1Binding } from '../db';
import { abuseLimits, answerGameSession, startGameSession, type GameServiceOptions } from '../game_service';
import { enforceRateLimit } from '../rate_limit';
import { getBearerToken, HttpError, jsonError, MAX_REQUEST_BODY_BYTES, parseJsonBody } from '../http';

export interface GameAuthVerifier {
  (token: string, env: FirebaseAuthEnv): Promise<FirebaseClaims>;
}

export interface GameRouteOptions extends GameServiceOptions {
  verifyToken?: GameAuthVerifier;
}

interface GameEnv extends FirebaseAuthEnv {
  DB: D1Binding;
}

export function createGameRouter(options: GameRouteOptions = {}) {
  const verifyToken = options.verifyToken ?? verifyFirebaseIdToken;
  return async (request: Request, env: GameEnv): Promise<Response> => {
    try {
      const userId = await authenticate(request, env, verifyToken);
      const url = new URL(request.url);
      if (request.method === 'POST' && url.pathname === '/v1/game/sessions') {
        await rejectBody(request, false);
        await enforceRateLimit(env.DB, 'session', userId, requestIp(request), abuseLimits(options), options.clock ?? (() => new Date()));
        return Response.json(await startGameSession(env.DB, userId, options), { status: 201 });
      }
      const match = url.pathname.match(/^\/v1\/game\/sessions\/([A-Za-z0-9_-]{43})\/answers$/);
      if (request.method === 'POST' && match) {
        await enforceRateLimit(env.DB, 'answer', userId, requestIp(request), abuseLimits(options), options.clock ?? (() => new Date()));
        const body = await parseJsonBody(request);
        const roundIndex = parseInteger(body.roundIndex);
        const optionId = parseInteger(body.optionId);
        const result = await answerGameSession(env.DB, match[1], userId, roundIndex, optionId, options);
        if (result.finished) {
          try {
            await saveAcceptedResult(env.DB, { userId, sessionId: match[1] }, options.clock);
          } catch {
            // Completion is already validated and persisted; publish can be retried.
          }
        }
        return Response.json(result);
      }
      const publishMatch = url.pathname.match(/^\/v1\/game\/sessions\/([A-Za-z0-9_-]{43})\/publish$/);
      if (request.method === 'POST' && publishMatch) {
        await rejectBody(request, false);
        await enforceRateLimit(env.DB, 'publish', userId, requestIp(request), abuseLimits(options), options.clock ?? (() => new Date()));
        const existing = await env.DB.prepare(`
           SELECT publish_count FROM game_sessions WHERE id = ?1 AND user_id = ?2
         `).bind(publishMatch[1], userId).first<{ publish_count: number }>();
        if (!existing) throw new HttpError('GAME_SESSION_NOT_FOUND', 'Game session was not found', 404);
        const alreadyPublished = await env.DB.prepare(
          'SELECT achieved_at FROM accepted_results WHERE session_id = ?1 AND user_id = ?2',
        ).bind(publishMatch[1], userId).first<{ achieved_at: string }>();
        if (alreadyPublished) {
          return Response.json({ state: 'published', published_at: alreadyPublished.achieved_at });
        }
        const [claimed] = await env.DB.batch([env.DB.prepare(`
          UPDATE game_sessions
          SET publish_count = publish_count + 1
          WHERE id = ?1 AND user_id = ?2 AND publish_count < ?3
        `).bind(publishMatch[1], userId, abuseLimits(options).maxPublishesPerSession)]);
        if (claimed.meta.changes !== 1) {
          throw new HttpError('GAME_PUBLISH_CAP', 'Game publication limit reached', 409);
        }
        const publication = await saveAcceptedResult(
          env.DB,
          { userId, sessionId: publishMatch[1] },
          options.clock,
        );
        return Response.json({ state: 'published', published_at: publication.publishedAt });
      }
      return jsonError(new HttpError('NOT_FOUND', 'Route was not found', 404));
    } catch (error) {
      return jsonError(error);
    }
  };
}

async function authenticate(request: Request, env: GameEnv, verifyToken: GameAuthVerifier): Promise<string> {
  const claims = await verifyToken(getBearerToken(request), env);
  return claims.sub;
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

async function rejectBody(request: Request, allowBody: boolean): Promise<void> {
  const value = request.headers.get('content-length');
  if (value && (!/^\d+$/.test(value) || Number(value) > MAX_REQUEST_BODY_BYTES)) {
    throw new HttpError('REQUEST_BODY_TOO_LARGE', 'Request body is too large', 413);
  }
  const bytes = request.body ? await request.arrayBuffer() : null;
  const size = bytes?.byteLength ?? 0;
  if (size > MAX_REQUEST_BODY_BYTES) {
    throw new HttpError('REQUEST_BODY_TOO_LARGE', 'Request body is too large', 413);
  }
  if (!allowBody && size > 0) {
    throw new HttpError('INVALID_JSON', 'Request body must be empty', 400);
  }
}

export const gameRouter = createGameRouter();
