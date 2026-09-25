import { describe, expect, it } from 'vitest';

import { evaluateMetric, FREE_TIER_DAILY_LIMITS } from '../src/free_tier';

describe('free-tier thresholds', () => {
  it('exposes conservative free-plan daily ceilings', () => {
    expect(FREE_TIER_DAILY_LIMITS).toEqual({
      workerRequests: 100_000,
      d1RowsRead: 5_000_000,
      d1RowsWritten: 100_000,
    });
  });

  it('marks ok, warn, and fail by ratio', () => {
    const base = {
      name: 'Workers requests (account)',
      limit: 100_000,
      scope: 'account' as const,
    };
    expect(evaluateMetric({ ...base, used: 10_000 }, 0.7, 0.85).level).toBe('ok');
    expect(evaluateMetric({ ...base, used: 70_000 }, 0.7, 0.85).level).toBe('warn');
    expect(evaluateMetric({ ...base, used: 85_000 }, 0.7, 0.85).level).toBe('fail');
  });
});
