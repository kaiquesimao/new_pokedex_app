import { Hono } from 'hono';

import { verifyFirebaseIdToken, type FirebaseAuthEnv } from '../auth';
import { getPublicProfile, upsertPublicProfile, type D1Binding } from '../db';
import { requireAuth, type AuthVerifier, type AuthVariables } from '../middleware/auth';
import { handleError, handleNotFound } from '../middleware/errors';
import { HttpError, parseJsonBody } from '../http';

export type ProfileAuthVerifier = AuthVerifier;

type ProfileBindings = FirebaseAuthEnv & { DB: D1Binding };
type ProfileEnv = { Bindings: ProfileBindings; Variables: AuthVariables };

/** Profile routes mounted at `/v1/me`. */
export function createProfileApp(options: { verifyToken?: ProfileAuthVerifier } = {}) {
  const verifyToken = options.verifyToken ?? verifyFirebaseIdToken;
  const app = new Hono<ProfileEnv>();

  app.onError(handleError);
  app.notFound(handleNotFound);
  app.use('*', requireAuth(verifyToken));

  app.get('/game-profile', async (c) =>
    c.json(toPayload(await getPublicProfile(c.env.DB, c.get('userId')))),
  );

  app.patch('/game-profile', async (c) => {
    const body = await parseJsonBody(c.req.raw);
    if (typeof body.isAnonymous !== 'boolean' || (body.displayName !== null && typeof body.displayName !== 'string')) {
      throw new HttpError('INVALID_JSON', 'Invalid game profile', 400);
    }
    const displayName = body.isAnonymous ? null : body.displayName as string | null;
    if (displayName !== null && (displayName.trim() !== displayName || displayName.length === 0 || displayName.length > 32)) {
      throw new HttpError('INVALID_JSON', 'Invalid game profile', 400);
    }
    const profile = await upsertPublicProfile(c.env.DB, {
      userId: c.get('userId'),
      displayName,
      avatarUrl: null,
      anonymous: body.isAnonymous,
    });
    return c.json(toPayload(profile));
  });

  app.all('/game-profile', () => {
    throw new HttpError('METHOD_NOT_ALLOWED', 'Method is not allowed', 405);
  });

  return app;
}

/** Fetch-compatible adapter for unit tests that call `(request, env)`. */
export function createProfileRouter(options: { verifyToken?: ProfileAuthVerifier } = {}) {
  const app = new Hono<{ Bindings: ProfileBindings }>();
  app.onError(handleError);
  app.notFound(handleNotFound);
  app.route('/v1/me', createProfileApp(options));
  return async (request: Request, env: ProfileBindings): Promise<Response> =>
    app.fetch(request, env);
}

function toPayload(profile: { displayName: string; anonymous: boolean }) {
  return { isAnonymous: profile.anonymous, displayName: profile.displayName };
}

export const profileRouter = createProfileRouter();
