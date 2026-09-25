# Backend Task 6 Implementation Plan

> **For agentic workers:** Execute this plan inline with tests-first checkpoints.

**Goal:** Harden the Guess the Pokemon Worker with free-tier-compatible abuse controls, complete deployment configuration, and verify the authenticated game flow.

**Architecture:** Use D1 as the durable coordination layer for fixed-window counters and game hard caps. Keep the catalog bundled in Worker assets and validate it plus migrations during build, so requests never call PokeAPI.

**Tech Stack:** TypeScript, Cloudflare Workers, D1, Wrangler, Vitest, Miniflare.

**Spec:** Approved Task 6 design in the conversation.

## Global Constraints

- No request-time PokeAPI calls.
- No secrets, real D1 IDs, or generated credentials committed.
- Stable JSON errors for all public failures.
- No git staging, commits, or pushes.
- Verify with `npm test`, `npm run typecheck`, `npm run build`, and `npm run dry-run`.

### Task 1: Abuse-control contract

**Files:** Modify `tests/game.test.ts`, `tests/http.test.ts`; create `src/rate_limit.ts`.

- [ ] Add failing tests for stable rate-limit errors, body cap, per-user/IP windows, and hard caps.
- [ ] Run the focused tests and confirm they fail for missing behavior.
- [ ] Implement D1-backed fixed-window counters and constants for request/body/session limits.
- [ ] Run focused tests until green.

### Task 2: Route integration

**Files:** Modify `src/routes/game.ts`, `src/index.ts`, `src/http.ts`, `src/game_service.ts`, `src/db.ts`; create `migrations/0003_rate_limits.sql` and integration tests.

- [ ] Add an authenticated start-answer-publish test and abuse rejection tests.
- [ ] Run them red.
- [ ] Integrate IP and user checks, session/answer/publish caps, and complete index routing.
- [ ] Run the full Vitest suite.

### Task 3: Deployment validation and documentation

**Files:** Modify `package.json`, `wrangler.toml`, `README.md`; create catalog/migration validation scripts if needed.

- [ ] Add validation commands to build/deploy/dry-run.
- [ ] Configure non-secret Firebase and API URL variables and a documented D1 placeholder.
- [ ] Document setup, quotas, migrations, catalog publishing, and no request-time PokeAPI.
- [ ] Run all requested verification commands.
