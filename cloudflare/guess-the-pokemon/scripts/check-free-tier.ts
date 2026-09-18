/**
 * Checks Cloudflare Workers + D1 free-tier daily usage via GraphQL Analytics.
 *
 * Env:
 *   CLOUDFLARE_API_TOKEN   required (Account Analytics Read + Workers/D1 read)
 *   CLOUDFLARE_ACCOUNT_ID  required
 *   WORKER_SCRIPT_NAME     optional (default: guess-the-pokemon)
 *   D1_DATABASE_ID         optional (default: production guess-the-pokemon D1)
 *   WARN_RATIO             optional (default: 0.7)
 *   FAIL_RATIO             optional (default: 0.85)
 */

import {
  evaluateMetric,
  FREE_TIER_DAILY_LIMITS,
  type UsageMetric,
} from '../src/free_tier';

const GRAPHQL_URL = 'https://api.cloudflare.com/client/v4/graphql';

function requireEnv(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`Missing required environment variable: ${name}`);
  return value;
}

function utcDayBounds(now = new Date()): {
  startDate: string;
  endDate: string;
  startIso: string;
  endIso: string;
} {
  const start = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const end = new Date(start.getTime() + 24 * 60 * 60 * 1000 - 1);
  const startDate = start.toISOString().slice(0, 10);
  return {
    startDate,
    endDate: startDate,
    startIso: start.toISOString(),
    endIso: end.toISOString(),
  };
}

async function graphql<T>(token: string, query: string, variables: Record<string, unknown>): Promise<T> {
  const response = await fetch(GRAPHQL_URL, {
    method: 'POST',
    headers: {
      authorization: `Bearer ${token}`,
      'content-type': 'application/json',
    },
    body: JSON.stringify({ query, variables }),
  });
  const payload = await response.json() as {
    data?: T;
    errors?: Array<{ message: string }>;
  };
  if (!response.ok || payload.errors?.length) {
    const detail = payload.errors?.map((error) => error.message).join('; ') || `HTTP ${response.status}`;
    throw new Error(`Cloudflare GraphQL failed: ${detail}`);
  }
  if (!payload.data) throw new Error('Cloudflare GraphQL returned no data');
  return payload.data;
}

interface WorkersResponse {
  viewer: {
    accounts: Array<{
      workersInvocationsAdaptive: Array<{
        sum: { requests: number };
        dimensions: { scriptName: string };
      }>;
    }>;
  };
}

interface D1Response {
  viewer: {
    accounts: Array<{
      d1AnalyticsAdaptiveGroups: Array<{
        sum: {
          rowsRead?: number;
          rowsWritten?: number;
          readQueries?: number;
          writeQueries?: number;
        };
        dimensions?: { databaseId?: string };
      }>;
    }>;
  };
}

function sumWorkerRequests(
  rows: WorkersResponse['viewer']['accounts'][0]['workersInvocationsAdaptive'],
  scriptName?: string,
): number {
  return rows
    .filter((row) => !scriptName || row.dimensions.scriptName === scriptName)
    .reduce((total, row) => total + (row.sum.requests ?? 0), 0);
}

function sumD1(
  rows: D1Response['viewer']['accounts'][0]['d1AnalyticsAdaptiveGroups'],
  databaseId?: string,
): { rowsRead: number; rowsWritten: number } {
  const filtered = rows.filter((row) => !databaseId || row.dimensions?.databaseId === databaseId);
  return filtered.reduce(
    (total, row) => ({
      rowsRead: total.rowsRead + (row.sum.rowsRead ?? row.sum.readQueries ?? 0),
      rowsWritten: total.rowsWritten + (row.sum.rowsWritten ?? row.sum.writeQueries ?? 0),
    }),
    { rowsRead: 0, rowsWritten: 0 },
  );
}

export async function collectFreeTierUsage(options: {
  token: string;
  accountId: string;
  scriptName: string;
  databaseId: string;
  now?: Date;
}): Promise<UsageMetric[]> {
  const bounds = utcDayBounds(options.now);
  const workers = await graphql<WorkersResponse>(options.token, `
    query WorkerUsage($accountTag: String!, $start: Time!, $end: Time!) {
      viewer {
        accounts(filter: { accountTag: $accountTag }) {
          workersInvocationsAdaptive(
            limit: 10000
            filter: { datetime_geq: $start, datetime_leq: $end }
          ) {
            sum { requests }
            dimensions { scriptName }
          }
        }
      }
    }
  `, {
    accountTag: options.accountId,
    start: bounds.startIso,
    end: bounds.endIso,
  });

  const d1 = await graphql<D1Response>(options.token, `
    query D1Usage($accountTag: String!, $start: Date!, $end: Date!) {
      viewer {
        accounts(filter: { accountTag: $accountTag }) {
          d1AnalyticsAdaptiveGroups(
            limit: 10000
            filter: { date_geq: $start, date_leq: $end }
          ) {
            sum {
              rowsRead
              rowsWritten
              readQueries
              writeQueries
            }
            dimensions { databaseId }
          }
        }
      }
    }
  `, {
    accountTag: options.accountId,
    start: bounds.startDate,
    end: bounds.endDate,
  });

  const workerRows = workers.viewer.accounts[0]?.workersInvocationsAdaptive ?? [];
  const d1Rows = d1.viewer.accounts[0]?.d1AnalyticsAdaptiveGroups ?? [];
  const accountWorkers = sumWorkerRequests(workerRows);
  const scriptWorkers = sumWorkerRequests(workerRows, options.scriptName);
  const accountD1 = sumD1(d1Rows);
  const databaseD1 = sumD1(d1Rows, options.databaseId);

  return [
    {
      name: 'Workers requests (account)',
      used: accountWorkers,
      limit: FREE_TIER_DAILY_LIMITS.workerRequests,
      scope: 'account',
    },
    {
      name: `Workers requests (${options.scriptName})`,
      used: scriptWorkers,
      limit: FREE_TIER_DAILY_LIMITS.workerRequests,
      scope: 'script',
    },
    {
      name: 'D1 rows read (account)',
      used: accountD1.rowsRead,
      limit: FREE_TIER_DAILY_LIMITS.d1RowsRead,
      scope: 'account',
    },
    {
      name: `D1 rows read (${options.databaseId.slice(0, 8)}…)`,
      used: databaseD1.rowsRead,
      limit: FREE_TIER_DAILY_LIMITS.d1RowsRead,
      scope: 'database',
    },
    {
      name: 'D1 rows written (account)',
      used: accountD1.rowsWritten,
      limit: FREE_TIER_DAILY_LIMITS.d1RowsWritten,
      scope: 'account',
    },
    {
      name: `D1 rows written (${options.databaseId.slice(0, 8)}…)`,
      used: databaseD1.rowsWritten,
      limit: FREE_TIER_DAILY_LIMITS.d1RowsWritten,
      scope: 'database',
    },
  ];
}

function formatPercent(ratio: number): string {
  return `${(ratio * 100).toFixed(1)}%`;
}

async function main(): Promise<void> {
  const token = requireEnv('CLOUDFLARE_API_TOKEN');
  const accountId = requireEnv('CLOUDFLARE_ACCOUNT_ID');
  const scriptName = process.env.WORKER_SCRIPT_NAME?.trim() || 'guess-the-pokemon';
  const databaseId = process.env.D1_DATABASE_ID?.trim()
    || 'ee058ebd-92d3-473e-b81b-2a7b4f7933fd';
  const warnRatio = Number(process.env.WARN_RATIO ?? '0.7');
  const failRatio = Number(process.env.FAIL_RATIO ?? '0.85');

  const metrics = await collectFreeTierUsage({
    token,
    accountId,
    scriptName,
    databaseId,
  });

  let worst: 'ok' | 'warn' | 'fail' = 'ok';
  console.log('Cloudflare free-tier usage (UTC day so far)');
  console.log(`Limits reset daily at 00:00 UTC. warn>=${formatPercent(warnRatio)} fail>=${formatPercent(failRatio)}`);
  console.log('');

  for (const metric of metrics) {
    const result = evaluateMetric(metric, warnRatio, failRatio);
    if (result.level === 'fail') worst = 'fail';
    else if (result.level === 'warn' && worst === 'ok') worst = 'warn';

    const line = `${result.level.toUpperCase().padEnd(4)} ${metric.name}: ${metric.used.toLocaleString('en-US')} / ${metric.limit.toLocaleString('en-US')} (${formatPercent(result.ratio)})`;
    if (result.level === 'fail') console.error(`::error::${line}`);
    else if (result.level === 'warn') console.warn(`::warning::${line}`);
    else console.log(line);
  }

  const accountFail = metrics
    .filter((metric) => metric.scope === 'account')
    .map((metric) => evaluateMetric(metric, warnRatio, failRatio))
    .some((result) => result.level === 'fail');

  if (accountFail || worst === 'fail') {
    process.exitCode = 1;
    return;
  }
  if (worst === 'warn') {
    console.log('\nUsage is elevated but still under the fail threshold.');
  }
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
