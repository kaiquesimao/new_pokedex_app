import { Hono } from 'hono';

import { chooseRound } from './catalog';
import { HttpError } from './http';
import { corsMiddleware } from './middleware/cors';
import { handleError, handleNotFound } from './middleware/errors';
import { createGameApp, createGameRouter } from './routes/game';
import { createLeaderboardApp, createLeaderboardRouter } from './routes/leaderboards';
import { createProfileApp, createProfileRouter } from './routes/profile';

type WorkerRouter = (request: Request, env: Cloudflare.Env) => Promise<Response>;

interface WorkerOptions {
  gameRouter?: WorkerRouter;
  leaderboardRouter?: WorkerRouter;
  profileRouter?: WorkerRouter;
}

export function createWorker(options: WorkerOptions = {}) {
  const useInjected = Boolean(
    options.gameRouter || options.leaderboardRouter || options.profileRouter,
  );
  if (useInjected) return createLegacyWorker(options);

  const app = new Hono<{ Bindings: Cloudflare.Env }>();
  app.use('*', corsMiddleware());
  app.onError(handleError);
  app.notFound(handleNotFound);

  // Mount by exclusive prefixes so auth middleware stays scoped per feature.
  app.route('/v1/game', createGameApp());
  app.route('/v1/leaderboards', createLeaderboardApp());
  app.route('/v1/me', createProfileApp());
  registerRoundRoutes(app);

  return app;
}

/** Keeps injectable `(request, env)` routers for createWorker({ gameRouter }) DI. */
function createLegacyWorker(options: WorkerOptions) {
  const routes = {
    gameRouter: options.gameRouter ?? createGameRouter() as WorkerRouter,
    leaderboardRouter: options.leaderboardRouter ?? createLeaderboardRouter() as WorkerRouter,
    profileRouter: options.profileRouter ?? createProfileRouter() as WorkerRouter,
  };

  const app = new Hono<{ Bindings: Cloudflare.Env }>();
  app.use('*', corsMiddleware());
  app.onError(handleError);
  app.notFound(handleNotFound);

  app.all('/v1/game/*', (c) => routes.gameRouter(c.req.raw, c.env));
  app.all('/v1/leaderboards', (c) => routes.leaderboardRouter(c.req.raw, c.env));
  app.all('/v1/me/game-profile', (c) => routes.profileRouter(c.req.raw, c.env));
  registerRoundRoutes(app);

  return app;
}

function registerRoundRoutes(app: Hono<{ Bindings: Cloudflare.Env }>): void {
  app.get('/round', (c) => {
    const url = new URL(c.req.url);
    const seed = singleQuery(url, 'seed') ?? 'default';
    const rawRound = singleQuery(url, 'round') ?? '0';
    if (seed.length === 0 || seed.length > 128 || !/^\d+$/.test(rawRound)) {
      throw new HttpError('INVALID_ROUND', 'Invalid round request', 400);
    }
    const round = Number(rawRound);
    if (!Number.isSafeInteger(round)) throw new HttpError('INVALID_ROUND', 'Invalid round request', 400);
    const selection = chooseRound(seed, round);
    return c.json({
      difficulty: selection.difficulty,
      silhouetteUrl: selection.target.spriteUrl,
      options: selection.options.map(({ isTarget: _, ...option }) => option),
    });
  });

  app.all('/round', () => {
    throw new HttpError('METHOD_NOT_ALLOWED', 'Method is not allowed', 405);
  });
}

function singleQuery(url: URL, name: string): string | null {
  const values = url.searchParams.getAll(name);
  if (values.length > 1) throw new HttpError('INVALID_ROUND', 'Invalid round request', 400);
  return values[0] ?? null;
}

const worker = createWorker();
export default worker;
