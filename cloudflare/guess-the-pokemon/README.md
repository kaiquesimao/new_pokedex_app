# Guess the Pokemon Worker

The Worker serves the game API at `GAME_API_BASE_URL`. Gameplay reads the
checked-in catalog from Worker assets; it never calls PokeAPI at request time.

## Configuration

Set these non-secret variables in `wrangler.toml` or an environment-specific
Wrangler config:

- `FIREBASE_PROJECT_ID`: Firebase project used to verify ID tokens.
- `GAME_API_BASE_URL`: deployed Worker URL used by the client.
- `CORS_ALLOWED_ORIGINS`: comma-separated HTTPS origins for the web app; do not
  use `*`.
- `DB`: D1 binding configured in `wrangler.toml`.

The default `wrangler.toml` values are safe placeholders. For separate
environments, use Wrangler environment sections such as
`[env.production.vars]` and deploy with `wrangler deploy --env production`.
Keep the production Firebase project, Worker URL, and app origins in that
environment configuration, not in application source code.

Set the cursor encryption key as a secret. It must decode from base64url to
exactly 32 bytes:

```shell
wrangler secret put CURSOR_ENCRYPTION_KEY
openssl rand -base64 32 | tr '+/' '-_' | tr -d '='
```

Do not commit secrets, real D1 IDs, local `.env` files, or generated keys.

## D1 And Catalog Deployment

Create the D1 database once, copy its returned ID into a local or CI-only
Wrangler environment, then apply migrations before deploying:

```shell
npm install
npx wrangler d1 create guess-the-pokemon
npm run validate:catalog
npm run validate:migrations
npx wrangler d1 migrations apply guess-the-pokemon --remote
npm run build
npm run dry-run
npm run deploy
```

The build fetches a catalog snapshot only during the explicit catalog build,
then validates version `v1`, all 1,025 IDs, required fields, and contiguous D1
migrations. Publish `catalog/catalog-v1.json` with the Worker deployment; no
PokeAPI request is made by `src/index.ts` or any game route.

Every response from the top-level Worker uses the JSON error envelope. CORS is
enabled only for origins listed in `CORS_ALLOWED_ORIGINS`; those origins may
use `OPTIONS` preflight for `GET`, `POST`, and `PATCH` requests.

## Free-Tier Limits

Limits are deliberately conservative and enforced by D1 fixed-window counters
keyed by both authenticated user and `CF-Connecting-IP`:

- 5 session starts, 30 answers, and 5 publishes per user and IP per minute.
- 3 active sessions per user.
- 20 answers and 2 publish attempts per session.
- 8 KiB maximum JSON request body.
- 10-minute maximum session lifetime.

Over-limit responses use stable JSON codes such as `RATE_LIMITED`,
`GAME_SESSION_CAP`, `GAME_ANSWER_CAP`, `GAME_PUBLISH_CAP`, and
`REQUEST_BODY_TOO_LARGE`. Old D1 rate-limit buckets are pruned opportunistically
as requests arrive, keeping the free-tier counter table bounded to recent
windows.

## Development

```shell
npm test
npm run typecheck
npm run ci
npm run dry-run
```

`npm run ci` validates the checked-in catalog (1,025 entries), contiguous D1
migrations, TypeScript, Vitest, and a Wrangler dry-run bundle. It does **not**
refetch PokeAPI.

Authenticated routes are under `/v1/game/`, `/v1/leaderboards`, and
`/v1/me/game-profile`. All game mutations require a Firebase Bearer token.

Production Worker URL:

```text
https://guess-the-pokemon.kaique-workspace.workers.dev
```

Set the same value as `GAME_API_BASE_URL` in the local gitignored
`dart_defines.json`. For a quick authenticated smoke against production:

```shell
# Write a Firebase ID token to .smoke-id-token.tmp, then:
npm run smoke:production
```

Free-tier usage (needs `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID`):

```shell
npm run monitor:free-tier
```

GitHub Actions runs the same Worker CI on every PR/push and deploys the Worker
from `master`. See the root README CI section.
