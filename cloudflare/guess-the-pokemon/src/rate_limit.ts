import { HttpError } from './http';
import type { Clock, D1Binding } from './db';

export interface AbuseLimits {
  sessionsPerWindow: number;
  answersPerWindow: number;
  publishesPerWindow: number;
  maxActiveSessions: number;
  maxAnswersPerSession: number;
  maxPublishesPerSession: number;
}

export const DEFAULT_ABUSE_LIMITS: AbuseLimits = {
  sessionsPerWindow: 5,
  answersPerWindow: 30,
  publishesPerWindow: 5,
  maxActiveSessions: 3,
  maxAnswersPerSession: 20,
  maxPublishesPerSession: 2,
};

const WINDOW_MS = 60_000;

export async function enforceRateLimit(
  db: D1Binding,
  scope: 'session' | 'answer' | 'publish',
  userId: string,
  ip: string,
  limits: AbuseLimits,
  clock: Clock,
): Promise<void> {
  const limit = scope === 'session'
    ? limits.sessionsPerWindow
    : scope === 'answer' ? limits.answersPerWindow : limits.publishesPerWindow;
  const windowStart = Math.floor(clock().getTime() / WINDOW_MS) * WINDOW_MS;
  await consume(db, `${scope}:user:${userId}`, windowStart, limit);
  await consume(db, `${scope}:ip:${ip}`, windowStart, limit);
}

async function consume(db: D1Binding, key: string, windowStart: number, limit: number): Promise<void> {
  await db.prepare('DELETE FROM rate_limit_buckets WHERE window_start < ?1')
    .bind(windowStart - WINDOW_MS)
    .run();
  const result = await db.prepare(`
    INSERT INTO rate_limit_buckets (bucket_key, window_start, request_count)
    VALUES (?1, ?2, 1)
    ON CONFLICT (bucket_key, window_start) DO UPDATE SET
      request_count = request_count + 1
    RETURNING request_count
  `).bind(key, windowStart).first<{ request_count: number }>();
  if (!result || result.request_count > limit) {
    throw new HttpError('RATE_LIMITED', 'Too many requests', 429);
  }
}
