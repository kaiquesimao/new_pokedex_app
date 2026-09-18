import { HttpError } from './http';

export interface D1Statement {
  bind(...values: unknown[]): D1Statement;
  all<T>(): Promise<{ results: T[] }>;
  first<T>(): Promise<T | null>;
  run(): Promise<{ meta: { changes: number; last_row_id?: number } }>;
}

export interface D1Binding {
  prepare(sql: string): D1Statement;
  batch(statements: D1Statement[]): Promise<Array<{ meta: { changes: number; last_row_id?: number } }>>;
  exec(sql: string): Promise<unknown>;
}

export type SessionState = 'active' | 'completed' | 'expired';

export interface Session {
  id: string;
  state: SessionState;
  score: number;
  currentRound: number;
  startedAt: string;
  expiresAt: string;
  completedAt: string | null;
}

export interface CreateSessionInput {
  id: string;
  userId: string;
  currentTargetId: number;
  seed?: string;
  now?: string;
  expiresAt: string;
  maxActiveSessions?: number;
}

export interface AnswerInput {
  sessionId: string;
  expectedRound: number;
  answerPokemonId: number;
}

export interface ServerAnswerContext {
  userId: string;
}

export interface AcceptedResultInput {
  userId: string;
  sessionId: string;
}

export interface AcceptedResultPublication {
  publishedAt: string;
}

export type Clock = () => Date;

export interface PublicProfileInput {
  userId: string;
  displayName: string | null;
  avatarUrl: string | null;
  anonymous: boolean;
}

export interface PublicProfile {
  displayName: string;
  avatarUrl: string | null;
  anonymous: boolean;
}

export interface LeaderboardEntry extends PublicProfile {
  rank: number;
  score: number;
  achievedAt: string;
  userId?: string;
  isCurrentUser?: boolean;
}

export interface LeaderboardInput {
  scope: 'weekly' | 'global';
  weekKey?: string;
  limit?: number;
  cursor?: LeaderboardCursor;
  currentUserId?: string;
  includeCursorUserId?: boolean;
}

export interface LeaderboardCursor {
  score: number;
  achievedAt: string;
  userId: string;
}

interface SessionRow {
  id: string;
  state: SessionState;
  current_target_id: number;
  last_answer_was_correct: number;
  score: number;
  current_round: number;
  started_at: string;
  expires_at: string;
  completed_at: string | null;
  publish_count?: number;
}

interface LeaderboardRow {
  user_id: string;
  score: number;
  achieved_at: string;
  display_name: string | null;
  avatar_url: string | null;
  is_anonymous: number;
}

const systemClock: Clock = () => new Date();

const now = (clock: Clock = systemClock): string => canonicalUtcTimestamp(clock());

export function canonicalUtcTimestamp(value: string | Date): string {
  if (value instanceof Date) {
    if (Number.isNaN(value.getTime())) throw new Error('Invalid UTC timestamp');
    return value.toISOString();
  }
  if (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/.test(value)) {
    throw new Error('Invalid UTC timestamp');
  }
  const date = new Date(value);
  if (Number.isNaN(date.getTime()) || date.toISOString() !== value) {
    throw new Error('Invalid UTC timestamp');
  }
  return value;
}

function timestampMillis(value: string): number {
  return Date.parse(canonicalUtcTimestamp(value));
}

export async function createSession(db: D1Binding, input: CreateSessionInput): Promise<Session> {
  if (!Number.isInteger(input.currentTargetId) || input.currentTargetId < 1) {
    throw new Error('Invalid current target ID');
  }
  const startedAt = canonicalUtcTimestamp(input.now ?? now());
  const expiresAt = canonicalUtcTimestamp(input.expiresAt);
  if (timestampMillis(expiresAt) <= timestampMillis(startedAt)) {
    throw new Error('Session expiry must be after start');
  }
  await ensurePublicPlayer(db, input.userId, startedAt);
  const [_cleanup, slot, session] = await db.batch([
    db.prepare(`
      DELETE FROM active_session_slots
      WHERE session_id IN (
        SELECT id FROM game_sessions WHERE state != 'active' OR expires_at <= ?1
      )
    `).bind(startedAt),
    db.prepare(`
      WITH slots(slot) AS (VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9))
      INSERT INTO active_session_slots (user_id, slot, session_id)
      SELECT ?1, slots.slot, ?2
      FROM slots
      WHERE slots.slot < ?3
        AND NOT EXISTS (
          SELECT 1 FROM active_session_slots AS active
          WHERE active.user_id = ?1 AND active.slot = slots.slot
        )
      LIMIT 1
    `).bind(input.userId, input.id, input.maxActiveSessions ?? 3),
    db.prepare(`
      INSERT INTO game_sessions (id, user_id, current_target_id, started_at, expires_at, seed)
      SELECT ?1, ?2, ?3, ?4, ?5, ?6
      WHERE EXISTS (SELECT 1 FROM active_session_slots WHERE session_id = ?1)
    `).bind(input.id, input.userId, input.currentTargetId, startedAt, expiresAt, input.seed ?? ''),
  ]);
  if (slot.meta.changes !== 1 || session.meta.changes !== 1) {
    throw new HttpError('GAME_SESSION_CAP', 'Too many active game sessions', 409);
  }

  return readSession(db, input.id);
}

export async function getSession(
  db: D1Binding,
  sessionId: string,
  userId: string,
  clock: Clock = systemClock,
): Promise<Session | null> {
  const atTimestamp = now(clock);
  const row = await db.prepare(`
    SELECT id, state, score, current_round, started_at, expires_at, completed_at
    FROM game_sessions
    WHERE id = ?1 AND user_id = ?2
  `).bind(sessionId, userId).first<SessionRow>();

  if (!row) return null;
  if (timestampMillis(atTimestamp) < timestampMillis(row.started_at)) {
    throw new Error('Timestamp precedes session start');
  }
  if (row.state === 'active' && timestampMillis(atTimestamp) >= timestampMillis(row.expires_at)) {
    await db.batch([
      db.prepare(`
        UPDATE game_sessions
        SET state = 'expired'
        WHERE id = ?1 AND state = 'active'
      `).bind(sessionId),
      db.prepare('DELETE FROM active_session_slots WHERE session_id = ?1').bind(sessionId),
    ]);
    row.state = 'expired';
  }
  return toSession(row);
}

export async function recordAnswer(
  db: D1Binding,
  input: AnswerInput,
  clock: Clock = systemClock,
  context: ServerAnswerContext,
): Promise<Session> {
  if (!Number.isInteger(input.expectedRound) || input.expectedRound < 0) {
    throw new Error('Unexpected round');
  }
  if (!Number.isInteger(input.answerPokemonId) || input.answerPokemonId < 1) {
    throw new Error('Invalid answer Pokemon ID');
  }
  const at = now(clock);
  const session = await getSession(db, input.sessionId, context.userId, clock);
  if (!session) throw new Error('Session was not found');
  if (session.state !== 'active') throw new Error('Session is not active');

  const [result] = await db.batch([db.prepare(`
    UPDATE game_sessions
    SET score = score + CASE WHEN ?1 = current_target_id THEN 1 ELSE 0 END,
        current_round = current_round + 1,
        last_answer_was_correct = CASE WHEN ?1 = current_target_id THEN 1 ELSE 0 END
    WHERE id = ?2 AND user_id = ?3 AND state = 'active'
      AND current_round = ?4 AND expires_at > ?5
  `).bind(input.answerPokemonId, input.sessionId, context.userId, input.expectedRound, at)]);
  if (result.meta.changes !== 1) {
    const current = await getSession(db, input.sessionId, context.userId, clock);
    if (!current) throw new Error('Session was not found');
    if (current.state !== 'active') throw new Error('Session is not active');
    throw new Error('Unexpected round');
  }

  return readSession(db, input.sessionId);
}

export async function advanceSessionTarget(
  db: D1Binding,
  input: { sessionId: string; userId: string; expectedRound: number; nextTargetId: number },
  clock: Clock = systemClock,
): Promise<Session> {
  if (!Number.isInteger(input.nextTargetId) || input.nextTargetId < 1) {
    throw new Error('Invalid next target ID');
  }
  const at = now(clock);
  const [result] = await db.batch([db.prepare(`
    UPDATE game_sessions
    SET current_target_id = ?1, last_answer_was_correct = 0
    WHERE id = ?2 AND user_id = ?3 AND state = 'active'
      AND current_round = ?4 AND expires_at > ?5 AND last_answer_was_correct = 1
  `).bind(input.nextTargetId, input.sessionId, input.userId, input.expectedRound, at)]);
  if (result.meta.changes !== 1) throw new Error('Session target could not be advanced');
  return readSession(db, input.sessionId);
}

export async function completeSession(
  db: D1Binding,
  sessionId: string,
  userId: string,
  clock: Clock = systemClock,
): Promise<Session> {
  const completedAt = now(clock);
  const session = await getSession(db, sessionId, userId, clock);
  if (!session) throw new Error('Session was not found');
  if (session.state !== 'active') throw new Error('Session is not active');
  const [result] = await db.batch([db.prepare(`
    UPDATE game_sessions
    SET state = 'completed', completed_at = ?1
    WHERE id = ?2 AND user_id = ?3 AND state = 'active' AND expires_at > ?1
  `).bind(completedAt, sessionId, userId)]);
  if (result.meta.changes !== 1) throw new Error('Session is not active');
  await db.prepare('DELETE FROM active_session_slots WHERE session_id = ?1').bind(sessionId).run();
  return readSession(db, sessionId);
}

export async function saveAcceptedResult(
  db: D1Binding,
  input: AcceptedResultInput,
  clock: Clock = systemClock,
): Promise<AcceptedResultPublication> {
  const currentTime = clock();
  const achievedAt = canonicalUtcTimestamp(currentTime);
  const weekKey = utcWeekKey(currentTime);
  const session = await db.prepare(`
    SELECT user_id, state, score, started_at
    FROM game_sessions
    WHERE id = ?1
  `).bind(input.sessionId).first<{ user_id: string; state: SessionState; score: number; started_at: string }>();
  if (!session) throw new Error('Session was not found');
  if (session.user_id !== input.userId) throw new Error('Session does not belong to user');
  if (session.state !== 'completed') throw new Error('Session is not completed');
  if (timestampMillis(achievedAt) < timestampMillis(session.started_at)) {
    throw new Error('Timestamp precedes session start');
  }
  const existing = await db.prepare(`
    SELECT achieved_at FROM accepted_results WHERE session_id = ?1
  `).bind(input.sessionId).first<{ achieved_at: string }>();
  if (existing) return { publishedAt: existing.achieved_at };

  await db.batch([
    db.prepare(`
    INSERT INTO accepted_results (id, user_id, session_id, score, achieved_at, created_at)
    VALUES (?1, ?2, ?3, ?4, ?5, ?6)
    ON CONFLICT (session_id) DO UPDATE SET
      score = excluded.score,
      achieved_at = excluded.achieved_at
  `).bind(input.sessionId, input.userId, input.sessionId, session.score, achievedAt, achievedAt),
    db.prepare(`
    INSERT INTO weekly_records (user_id, week_key, score, achieved_at, accepted_result_id)
    VALUES (?1, ?2, ?3, ?4, ?5)
    ON CONFLICT (user_id, week_key) DO UPDATE SET
      score = excluded.score,
      achieved_at = excluded.achieved_at,
      accepted_result_id = excluded.accepted_result_id
    WHERE excluded.score > weekly_records.score
       OR (excluded.score = weekly_records.score AND excluded.achieved_at < weekly_records.achieved_at)
  `).bind(input.userId, weekKey, session.score, achievedAt, input.sessionId),
    db.prepare(`
    INSERT INTO global_records (user_id, score, achieved_at, accepted_result_id)
    VALUES (?1, ?2, ?3, ?4)
    ON CONFLICT (user_id) DO UPDATE SET
      score = excluded.score,
      achieved_at = excluded.achieved_at,
      accepted_result_id = excluded.accepted_result_id
    WHERE excluded.score > global_records.score
       OR (excluded.score = global_records.score AND excluded.achieved_at < global_records.achieved_at)
  `).bind(input.userId, session.score, achievedAt, input.sessionId),
  ]);
  return { publishedAt: achievedAt };
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

export async function getLeaderboard(
  db: D1Binding,
  input: LeaderboardInput,
): Promise<LeaderboardEntry[]> {
  if (input.scope !== 'weekly' && input.scope !== 'global') {
    throw new Error('Invalid leaderboard scope');
  }
  const limit = Math.max(1, Math.min(input.limit ?? 50, 100));
  const table = input.scope === 'weekly' ? 'weekly_records' : 'global_records';
  const baseConditions = ['1 = 1'];
  const baseValues: unknown[] = [];
  if (input.scope === 'weekly') {
    if (!input.weekKey || input.weekKey.length > 20) throw new Error('Invalid week key');
    baseConditions.push(`records.week_key = ?${baseValues.length + 1}`);
    baseValues.push(input.weekKey);
  }
  let rankOffset = 0;
  if (input.cursor) {
    const cursorTimestamp = canonicalUtcTimestamp(input.cursor.achievedAt);
    const before = await db.prepare(`
      SELECT COUNT(*) AS count
      FROM ${table} AS records
      WHERE ${baseConditions.join(' AND ')}
        AND (records.score > ?${baseValues.length + 1}
          OR (records.score = ?${baseValues.length + 1}
            AND (records.achieved_at < ?${baseValues.length + 2}
              OR (records.achieved_at = ?${baseValues.length + 2}
                AND records.user_id <= ?${baseValues.length + 3}))))
    `).bind(...baseValues, input.cursor.score, cursorTimestamp, input.cursor.userId).first<{ count: number }>();
    rankOffset = before?.count ?? 0;
  }
  const conditions = [...baseConditions];
  const values = [...baseValues];
  if (input.cursor) {
    const cursorTimestamp = canonicalUtcTimestamp(input.cursor.achievedAt);
    conditions.push(`(records.score < ?${values.length + 1} OR (records.score = ?${values.length + 1} AND (records.achieved_at > ?${values.length + 2} OR (records.achieved_at = ?${values.length + 2} AND records.user_id > ?${values.length + 3}))))`);
    values.push(input.cursor.score, cursorTimestamp, input.cursor.userId);
  }
  values.push(limit);
  const limitParameter = `?${values.length}`;
  const rows = await db.prepare(`
    SELECT records.user_id, records.score, records.achieved_at, profile.display_name,
      profile.avatar_url, profile.is_anonymous
    FROM ${table} AS records
    JOIN public_players AS profile ON profile.user_id = records.user_id
    WHERE ${conditions.join(' AND ')}
    ORDER BY records.score DESC, records.achieved_at ASC, records.user_id ASC
    LIMIT ${limitParameter}
  `).bind(...values).all<LeaderboardRow>();

  return rows.results.map((row, index) => ({
    rank: rankOffset + index + 1,
    score: row.score,
    achievedAt: row.achieved_at,
    displayName: row.is_anonymous ? 'Treinador anonimo' : row.display_name ?? 'Treinador',
    avatarUrl: row.is_anonymous ? null : row.avatar_url,
    anonymous: Boolean(row.is_anonymous),
    ...(input.currentUserId || input.includeCursorUserId ? {
      userId: row.user_id,
      ...(input.currentUserId ? { isCurrentUser: row.user_id === input.currentUserId } : {}),
    } : {}),
  }));
}

export async function getPublicProfile(db: D1Binding, userId: string): Promise<PublicProfile> {
  const row = await db.prepare(`
    SELECT display_name, avatar_url, is_anonymous
    FROM public_players WHERE user_id = ?1
  `).bind(userId).first<{ display_name: string | null; avatar_url: string | null; is_anonymous: number }>();
  if (!row) return { displayName: 'Treinador anonimo', avatarUrl: null, anonymous: true };
  return {
    displayName: row.is_anonymous ? 'Treinador anonimo' : row.display_name ?? 'Treinador',
    avatarUrl: row.is_anonymous ? null : row.avatar_url,
    anonymous: Boolean(row.is_anonymous),
  };
}

export async function upsertPublicProfile(
  db: D1Binding,
  input: PublicProfileInput,
): Promise<PublicProfile> {
  const timestamp = now();
  await db.prepare(`
    INSERT INTO public_players (user_id, display_name, avatar_url, is_anonymous, created_at, updated_at)
    VALUES (?1, ?2, ?3, ?4, ?5, ?5)
    ON CONFLICT (user_id) DO UPDATE SET
      display_name = excluded.display_name,
      avatar_url = excluded.avatar_url,
      is_anonymous = excluded.is_anonymous,
      updated_at = excluded.updated_at
  `).bind(input.userId, input.displayName, input.avatarUrl, input.anonymous ? 1 : 0, timestamp).run();

  return {
    displayName: input.anonymous ? 'Treinador anonimo' : input.displayName ?? 'Treinador',
    avatarUrl: input.anonymous ? null : input.avatarUrl,
    anonymous: input.anonymous,
  };
}

async function ensurePublicPlayer(db: D1Binding, userId: string, timestamp: string): Promise<void> {
  await db.prepare(`
    INSERT INTO public_players (user_id, is_anonymous, created_at, updated_at)
    VALUES (?1, 1, ?2, ?2)
    ON CONFLICT (user_id) DO NOTHING
  `).bind(userId, timestamp).run();
}

async function readSession(db: D1Binding, id: string): Promise<Session> {
  const row = await db.prepare(`
    SELECT id, state, score, current_round, started_at, expires_at, completed_at
    FROM game_sessions WHERE id = ?1
  `).bind(id).first<SessionRow>();
  if (!row) throw new Error('Session was not found');
  return toSession(row);
}

function toSession(row: SessionRow): Session {
  return {
    id: row.id,
    state: row.state,
    score: row.score,
    currentRound: row.current_round,
    startedAt: row.started_at,
    expiresAt: row.expires_at,
    completedAt: row.completed_at,
  };
}
