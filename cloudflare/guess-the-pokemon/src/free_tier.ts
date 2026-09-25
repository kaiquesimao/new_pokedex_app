export const FREE_TIER_DAILY_LIMITS = {
  workerRequests: 100_000,
  d1RowsRead: 5_000_000,
  d1RowsWritten: 100_000,
} as const;

export interface UsageMetric {
  name: string;
  used: number;
  limit: number;
  scope: 'account' | 'script' | 'database';
}

export interface ThresholdResult {
  level: 'ok' | 'warn' | 'fail';
  ratio: number;
  metric: UsageMetric;
}

export function evaluateMetric(
  metric: UsageMetric,
  warnRatio: number,
  failRatio: number,
): ThresholdResult {
  const ratio = metric.limit === 0 ? 0 : metric.used / metric.limit;
  const level = ratio >= failRatio ? 'fail' : ratio >= warnRatio ? 'warn' : 'ok';
  return { level, ratio, metric };
}
