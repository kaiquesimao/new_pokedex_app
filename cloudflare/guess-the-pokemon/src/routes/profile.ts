import { verifyFirebaseIdToken, type FirebaseClaims, type FirebaseAuthEnv } from '../auth';
import { getPublicProfile, upsertPublicProfile, type D1Binding } from '../db';
import { getBearerToken, HttpError, jsonError, parseJsonBody } from '../http';

export interface ProfileAuthVerifier {
  (token: string, env: FirebaseAuthEnv): Promise<FirebaseClaims>;
}

interface ProfileEnv extends FirebaseAuthEnv { DB: D1Binding }

export function createProfileRouter(options: { verifyToken?: ProfileAuthVerifier } = {}) {
  const verifyToken = options.verifyToken ?? verifyFirebaseIdToken;
  return async (request: Request, env: ProfileEnv): Promise<Response> => {
    try {
      const claims = await verifyToken(getBearerToken(request), env);
      if (request.method === 'GET') return Response.json(toPayload(await getPublicProfile(env.DB, claims.sub)));
      if (request.method !== 'PATCH') return jsonError(new HttpError('METHOD_NOT_ALLOWED', 'Method is not allowed', 405));
      const body = await parseJsonBody(request);
      if (typeof body.isAnonymous !== 'boolean' || (body.displayName !== null && typeof body.displayName !== 'string')) {
        throw new HttpError('INVALID_JSON', 'Invalid game profile', 400);
      }
      const displayName = body.isAnonymous ? null : body.displayName as string | null;
      if (displayName !== null && (displayName.trim() !== displayName || displayName.length === 0 || displayName.length > 32)) {
        throw new HttpError('INVALID_JSON', 'Invalid game profile', 400);
      }
      const profile = await upsertPublicProfile(env.DB, {
        userId: claims.sub,
        displayName,
        avatarUrl: null,
        anonymous: body.isAnonymous,
      });
      return Response.json(toPayload(profile));
    } catch (error) {
      return jsonError(error);
    }
  };
}

function toPayload(profile: { displayName: string; anonymous: boolean }) {
  return { isAnonymous: profile.anonymous, displayName: profile.displayName };
}

export const profileRouter = createProfileRouter();
