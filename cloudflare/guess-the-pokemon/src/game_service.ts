import { CATALOG, chooseRound, type CatalogEntry, type RoundSelection } from './catalog';
import { canonicalUtcTimestamp, createSession, type Clock, type D1Binding } from './db';
import { HttpError } from './http';
import { DEFAULT_ABUSE_LIMITS, type AbuseLimits } from './rate_limit';

export const CATALOG_VERSION = 'v1';
export const SESSION_TTL_MS = 10 * 60 * 1000;

export interface GameRound {
  roundIndex: number;
  difficulty: string;
  options: Array<Omit<CatalogEntry, 'difficulty'>>;
  silhouetteUrl: string;
}

export interface GameSessionStart {
  sessionId: string;
  catalogVersion: string;
  round: GameRound;
}

export interface GameAnswerResult {
  sessionId: string;
  roundIndex: number;
  correct: boolean;
  finished: boolean;
  score: number;
  correctPokemonName: string;
  correctSpriteUrl: string;
  nextRound?: GameRound;
}

export interface GameServiceOptions {
  clock?: Clock;
  randomBytes?: (length: number) => Uint8Array;
  limits?: Partial<AbuseLimits>;
}

export function abuseLimits(options: GameServiceOptions): AbuseLimits {
  return { ...DEFAULT_ABUSE_LIMITS, ...options.limits };
}

interface GameSessionRow {
  id: string;
  user_id: string;
  seed: string;
  current_target_id: number;
  current_round: number;
  score: number;
  state: 'active' | 'completed' | 'expired';
  expires_at: string;
  last_answer_round: number | null;
  last_answer_option_id: number | null;
  last_answer_response: string | null;
}

const systemClock: Clock = () => new Date();
const secureRandomBytes = (length: number): Uint8Array => crypto.getRandomValues(new Uint8Array(length));

export async function startGameSession(
  db: D1Binding,
  userId: string,
  options: GameServiceOptions = {},
): Promise<GameSessionStart> {
  const clock = options.clock ?? systemClock;
  const randomBytes = options.randomBytes ?? secureRandomBytes;
  const startedAt = canonicalUtcTimestamp(clock());
  const sessionId = encodeBase64url(randomBytes(32));
  const seed = encodeBase64url(randomBytes(32));
  const selection = chooseRound(seed, 0);
  const expiresAt = canonicalUtcTimestamp(new Date(Date.parse(startedAt) + SESSION_TTL_MS));

  await createSession(db, {
    id: sessionId,
    userId,
    seed,
    currentTargetId: selection.target.id,
    now: startedAt,
    expiresAt,
    maxActiveSessions: abuseLimits(options).maxActiveSessions,
  });

  return { sessionId, catalogVersion: CATALOG_VERSION, round: publicRound(selection, 0) };
}

export async function answerGameSession(
  db: D1Binding,
  sessionId: string,
  userId: string,
  roundIndex: number,
  optionId: number,
  options: GameServiceOptions = {},
): Promise<GameAnswerResult> {
  const clock = options.clock ?? systemClock;
  const at = canonicalUtcTimestamp(clock());
  const session = await db.prepare(`
    SELECT id, user_id, seed, current_target_id, current_round, score, state, expires_at,
      last_answer_round, last_answer_option_id, last_answer_response
    FROM game_sessions WHERE id = ?1 AND user_id = ?2
  `).bind(sessionId, userId).first<GameSessionRow>();
  if (!session) throw new HttpError('GAME_SESSION_NOT_FOUND', 'Game session was not found', 404);
  if (session.last_answer_round === roundIndex &&
      session.last_answer_option_id === optionId && session.last_answer_response) {
    return JSON.parse(session.last_answer_response) as GameAnswerResult;
  }

  if (session.state === 'expired' || Date.parse(at) >= Date.parse(session.expires_at)) {
    await db.batch([
      db.prepare(`UPDATE game_sessions SET state = 'expired' WHERE id = ?1 AND state = 'active'`).bind(sessionId),
      db.prepare('DELETE FROM active_session_slots WHERE session_id = ?1').bind(sessionId),
    ]);
    throw new HttpError('GAME_SESSION_EXPIRED', 'Game session has expired', 410);
  }
  if (session.state !== 'active') throw new HttpError('GAME_SESSION_FINISHED', 'Game session is finished', 409);
  if (session.current_round >= abuseLimits(options).maxAnswersPerSession) {
    throw new HttpError('GAME_ANSWER_CAP', 'Game answer limit reached', 409);
  }
  if (session.current_round !== roundIndex) {
    throw new HttpError('GAME_ROUND_ORDER', 'Game round is out of order', 409);
  }

  const correct = optionId === session.current_target_id;
  const nextIndex = roundIndex + 1;
  const nextSelection = correct ? chooseRound(session.seed, nextIndex) : undefined;
  const target = CATALOG.find((entry) => entry.id === session.current_target_id);
  if (!target) {
    throw new HttpError('GAME_CATALOG_MISMATCH', 'Game catalog target is missing', 500);
  }
  const response: GameAnswerResult = {
    sessionId,
    roundIndex,
    correct,
    finished: !correct,
    score: session.score + (correct ? 1 : 0),
    correctPokemonName: target.label,
    correctSpriteUrl: target.spriteUrl,
    ...(nextSelection ? { nextRound: publicRound(nextSelection, nextIndex) } : {}),
  };
  const statements = [db.prepare(`
    UPDATE game_sessions
    SET current_round = current_round + 1,
        score = score + CASE WHEN ?1 = current_target_id THEN 1 ELSE 0 END,
        current_target_id = CASE WHEN ?1 = current_target_id THEN ?2 ELSE current_target_id END,
        last_answer_was_correct = CASE WHEN ?1 = current_target_id THEN 1 ELSE 0 END,
        state = CASE WHEN ?1 = current_target_id THEN 'active' ELSE 'completed' END,
        completed_at = CASE WHEN ?1 = current_target_id THEN NULL ELSE ?4 END,
        last_answer_round = ?7,
        last_answer_option_id = ?1,
        last_answer_response = ?8
    WHERE id = ?5 AND user_id = ?6 AND state = 'active'
      AND current_round = ?7 AND expires_at > ?4
   `).bind(optionId, nextSelection?.target.id ?? session.current_target_id, at, at, sessionId, userId, roundIndex, JSON.stringify(response))];
  if (!correct) {
    statements.push(db.prepare('DELETE FROM active_session_slots WHERE session_id = ?1').bind(sessionId));
  }
  const [result] = await db.batch(statements);
  if (result.meta.changes !== 1) throw new HttpError('GAME_ROUND_ORDER', 'Game round is out of order', 409);

  return response;
}

function publicRound(selection: RoundSelection, roundIndex: number): GameRound {
  return {
    roundIndex,
    difficulty: selection.difficulty,
    silhouetteUrl: selection.target.spriteUrl,
    options: selection.options.map(({ difficulty: _, isTarget: __, ...option }) => option),
  };
}

function encodeBase64url(bytes: Uint8Array): string {
  let binary = '';
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll('+', '-').replaceAll('/', '_').replace(/=+$/, '');
}
