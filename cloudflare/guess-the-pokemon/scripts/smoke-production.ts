import { readFileSync, unlinkSync } from 'node:fs';
import { resolve } from 'node:path';

const base = process.env.GAME_API_BASE_URL ?? 'https://guess-the-pokemon.kaique-workspace.workers.dev';
const token = readFileSync(resolve('.smoke-id-token.tmp'), 'utf8').trim();
const uid = JSON.parse(Buffer.from(token.split('.')[1], 'base64url').toString('utf8')).user_id as string;

type Option = { id: number };
type Round = { roundIndex: number; silhouetteUrl: string; options: Option[] };

async function api(method: string, path: string, body?: unknown) {
  const headers: Record<string, string> = { Authorization: `Bearer ${token}` };
  let payload: string | undefined;
  if (body !== undefined) {
    headers['Content-Type'] = 'application/json';
    payload = JSON.stringify(body);
  }
  const response = await fetch(`${base}${path}`, { method, headers, body: payload });
  const text = await response.text();
  let json: any = null;
  try { json = JSON.parse(text); } catch { /* ignore */ }
  return { status: response.status, text, json, headers: response.headers };
}

function targetFromRound(round: Round): number {
  const match = round.silhouetteUrl.match(/\/(\d+)\.png(?:\?|$)/);
  if (!match) throw new Error(`Cannot parse silhouette: ${round.silhouetteUrl}`);
  return Number(match[1]);
}

function assert(condition: unknown, message: string) {
  if (!condition) throw new Error(message);
}

const results: string[] = [];

const startWrong = await api('POST', '/v1/game/sessions');
assert(startWrong.status === 201, `start wrong session: ${startWrong.status} ${startWrong.text}`);
const wrongTarget = targetFromRound(startWrong.json.round);
const wrongOption = startWrong.json.round.options.find((option: Option) => option.id !== wrongTarget).id;
const wrongAnswer = await api('POST', `/v1/game/sessions/${startWrong.json.sessionId}/answers`, {
  roundIndex: 0,
  optionId: wrongOption,
});
assert(
  wrongAnswer.json?.correct === false && wrongAnswer.json?.finished === true && wrongAnswer.json?.score === 0,
  `wrong answer failed: ${wrongAnswer.text}`,
);
results.push('PASS wrong answer finishes with score 0');

const start = await api('POST', '/v1/game/sessions');
assert(start.status === 201, `start session: ${start.status} ${start.text}`);
const sessionId = start.json.sessionId as string;
let round = start.json.round as Round;

const forged = await api('POST', `/v1/game/sessions/${sessionId}/answers`, {
  roundIndex: 0,
  optionId: 999_999,
});
assert(
  forged.json?.correct === false && forged.json?.finished === true && forged.json?.score === 0,
  `forged answer changed score: ${forged.text}`,
);
results.push('PASS forged optionId does not increase score');

const startOk = await api('POST', '/v1/game/sessions');
assert(startOk.status === 201, `start ok session: ${startOk.status} ${startOk.text}`);
const okSessionId = startOk.json.sessionId as string;
round = startOk.json.round as Round;
const target = targetFromRound(round);
const correct = await api('POST', `/v1/game/sessions/${okSessionId}/answers`, {
  roundIndex: round.roundIndex,
  optionId: target,
});
assert(correct.json?.correct === true && correct.json?.score === 1, `correct answer failed: ${correct.text}`);
results.push('PASS correct answer increments score');

const replay = await api('POST', `/v1/game/sessions/${okSessionId}/answers`, {
  roundIndex: 0,
  optionId: target,
});
assert(replay.json?.correct === true && replay.json?.score === 1, `idempotent replay failed: ${replay.text}`);
results.push('PASS identical replay is idempotent');

round = correct.json.nextRound as Round;
const missOption = round.options.find((option: Option) => option.id !== targetFromRound(round));
if (!missOption) throw new Error('expected a non-target option to finish the session');
const finish = await api('POST', `/v1/game/sessions/${okSessionId}/answers`, {
  roundIndex: round.roundIndex,
  optionId: missOption.id,
});
assert(finish.json?.finished === true && finish.json?.score === 1, `finish failed: ${finish.text}`);
results.push('PASS incorrect answer finishes session');

const publish1 = await api('POST', `/v1/game/sessions/${okSessionId}/publish`);
const publish2 = await api('POST', `/v1/game/sessions/${okSessionId}/publish`);
assert(publish1.status === 200 && publish2.status === 200, `publish failed: ${publish1.text} / ${publish2.text}`);
assert(publish1.json?.state === 'published' && publish2.json?.state === 'published', 'publish not idempotent');
results.push('PASS publish retry is idempotent');

const globalBoard = await api('GET', '/v1/leaderboards?scope=global&limit=5');
const weeklyBoard = await api('GET', '/v1/leaderboards?scope=weekly&limit=5');
assert(globalBoard.status === 200 && weeklyBoard.status === 200, 'leaderboards failed');
assert(!globalBoard.text.includes(uid) && !globalBoard.text.includes('@'), `PII leaked: ${globalBoard.text}`);
assert(Array.isArray(globalBoard.json.entries) && globalBoard.json.entries.length >= 1, 'expected ranking entry');
assert(!('userId' in (globalBoard.json.entries[0] ?? {})), 'userId exposed in ranking');
results.push('PASS weekly/global leaderboards without uid/email');

const page = await api('GET', `/v1/leaderboards?scope=global&limit=1&cursor=${encodeURIComponent(globalBoard.json.next_cursor ?? '')}`);
if (globalBoard.json.next_cursor) {
  assert(page.status === 200, `pagination failed: ${page.text}`);
  assert(!page.text.includes(uid), 'cursor page leaked uid');
  results.push('PASS ranking pagination');
} else {
  results.push('PASS ranking pagination skipped (single page)');
}

const corsOk = await fetch(`${base}/v1/leaderboards?scope=global&limit=1`, {
  method: 'OPTIONS',
  headers: {
    Origin: 'https://pokedex-app-c5e90.web.app',
    'Access-Control-Request-Method': 'GET',
    'Access-Control-Request-Headers': 'authorization,content-type,x-pokedata-client',
  },
});
assert(corsOk.status === 204, `cors preflight failed: ${corsOk.status}`);
assert(corsOk.headers.get('access-control-allow-origin') === 'https://pokedex-app-c5e90.web.app', 'cors origin missing');
assert(
  corsOk.headers.get('access-control-allow-headers')?.toLowerCase().includes('x-pokedata-client'),
  'cors allow-headers missing X-PokeData-Client',
);
assert(corsOk.headers.get('vary')?.toLowerCase().includes('origin'), 'vary origin missing');
results.push('PASS CORS preflight for production web origin');

let rateHit = false;
for (let i = 0; i < 10; i += 1) {
  const burst = await api('POST', '/v1/game/sessions');
  if (burst.status === 429 || ['RATE_LIMITED', 'GAME_SESSION_CAP'].includes(burst.json?.error?.code)) {
    rateHit = true;
    results.push(`PASS rate/session cap stable code=${burst.json?.error?.code}`);
    break;
  }
}
assert(rateHit, 'expected RATE_LIMITED or GAME_SESSION_CAP');

console.log(results.join('\n'));
console.log('SMOKE_OK');
try { unlinkSync(resolve('.smoke-id-token.tmp')); } catch { /* ignore */ }
