import { chooseRound } from './catalog';
import { HttpError, jsonError } from './http';
import { gameRouter } from './routes/game';
import { leaderboardRouter } from './routes/leaderboards';
import { profileRouter } from './routes/profile';

type WorkerRouter = (request: Request, env: Cloudflare.Env) => Promise<Response>;

interface WorkerOptions {
  gameRouter?: WorkerRouter;
  leaderboardRouter?: WorkerRouter;
  profileRouter?: WorkerRouter;
}

export function createWorker(options: WorkerOptions = {}) {
  const routes = {
    gameRouter: options.gameRouter ?? gameRouter as WorkerRouter,
    leaderboardRouter: options.leaderboardRouter ?? leaderboardRouter as WorkerRouter,
    profileRouter: options.profileRouter ?? profileRouter as WorkerRouter,
  };

  return {
    async fetch(request: Request, env: Cloudflare.Env): Promise<Response> {
      try {
        const url = new URL(request.url);
        const origin = request.headers.get('origin');
        if (origin && !isAllowedOrigin(origin, env)) {
          return withCors(jsonError(new HttpError('CORS_ORIGIN_NOT_ALLOWED', 'Origin is not allowed', 403)), request, env);
        }
        if (request.method === 'OPTIONS') {
          if (!isKnownPath(url.pathname)) return withCors(notFound(), request, env);
          return withCors(new Response(null, { status: 204 }), request, env);
        }
        if (url.pathname.startsWith('/v1/game/')) {
          return withCors(await routes.gameRouter(request, env), request, env);
        }
        if (url.pathname === '/v1/leaderboards') {
          return withCors(await routes.leaderboardRouter(request, env), request, env);
        }
        if (url.pathname === '/v1/me/game-profile') {
          return withCors(await routes.profileRouter(request, env), request, env);
        }
        if (url.pathname !== '/round') return withCors(notFound(), request, env);
        if (request.method !== 'GET') {
          return withCors(jsonError(new HttpError('METHOD_NOT_ALLOWED', 'Method is not allowed', 405)), request, env);
        }
        const seed = singleQuery(url, 'seed') ?? 'default';
        const rawRound = singleQuery(url, 'round') ?? '0';
        if (seed.length === 0 || seed.length > 128 || !/^\d+$/.test(rawRound)) {
          throw new HttpError('INVALID_ROUND', 'Invalid round request', 400);
        }
        const round = Number(rawRound);
        if (!Number.isSafeInteger(round)) throw new HttpError('INVALID_ROUND', 'Invalid round request', 400);
        const selection = chooseRound(seed, round);
        return withCors(Response.json({
          difficulty: selection.difficulty,
          silhouetteUrl: selection.target.spriteUrl,
          options: selection.options.map(({ isTarget: _, ...option }) => option),
        }), request, env);
      } catch (error) {
        return withCors(jsonError(error), request, env);
      }
    },
  };
}

function singleQuery(url: URL, name: string): string | null {
  const values = url.searchParams.getAll(name);
  if (values.length > 1) throw new HttpError('INVALID_ROUND', 'Invalid round request', 400);
  return values[0] ?? null;
}

function isKnownPath(pathname: string): boolean {
  return pathname === '/round' || pathname === '/v1/leaderboards'
    || pathname === '/v1/me/game-profile' || pathname.startsWith('/v1/game/');
}

function notFound(): Response {
  return jsonError(new HttpError('NOT_FOUND', 'Route was not found', 404));
}

function allowedOrigins(env: Cloudflare.Env): Set<string> {
  const configured = (env as Cloudflare.Env & { CORS_ALLOWED_ORIGINS?: string }).CORS_ALLOWED_ORIGINS ?? '';
  return new Set(configured.split(',').map((origin: string) => origin.trim()).filter(Boolean));
}

/** Flutter web / Chrome local debugging (Android/iOS clients do not send Origin). */
function isLocalDevOrigin(origin: string): boolean {
  try {
    const url = new URL(origin);
    return url.protocol === 'http:'
      && (url.hostname === 'localhost' || url.hostname === '127.0.0.1');
  } catch {
    return false;
  }
}

function isAllowedOrigin(origin: string, env: Cloudflare.Env): boolean {
  return allowedOrigins(env).has(origin) || isLocalDevOrigin(origin);
}

function withCors(response: Response, request: Request, env: Cloudflare.Env): Response {
  const headers = new Headers(response.headers);
  headers.set('vary', 'Origin');
  const origin = request.headers.get('origin');
  if (origin && isAllowedOrigin(origin, env)) {
    headers.set('access-control-allow-origin', origin);
    headers.set('access-control-allow-methods', 'GET, POST, PATCH, OPTIONS');
    // Flutter web Dio sends X-PokeData-Client; omitting it fails browser preflight.
    headers.set(
      'access-control-allow-headers',
      'Authorization, Content-Type, X-PokeData-Client',
    );
    headers.set('access-control-max-age', '600');
  }
  return new Response(response.body, { status: response.status, headers });
}

const worker = createWorker();
export default worker;
