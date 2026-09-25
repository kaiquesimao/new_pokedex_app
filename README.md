# PokeData

A modern Pokédex for fans — browse Pokémon, regions, and details; sync favorites across devices; play **Guess the Pokémon**.

Built with **Flutter** for **Android** and **Web** (mobile-first). Published on Google Play and on the web.

**Português:** [README.pt-BR.md](README.pt-BR.md)

| | |
|---|---|
| **Google Play** | [Pokedata: Pokedex](https://play.google.com/store/apps/details?id=com.kaiquesimao.pokedex) |
| **Web** | [https://pokedata.kaique.site](https://pokedata.kaique.site) |
| **Package** | `com.kaiquesimao.pokedex` |

---

## Overview

PokeData is a fan-made reference app focused on everyday use: fast search, readable detail screens, and navigation that stays out of the way. Guests can explore the full Pokédex without an account; signing in unlocks synced favorites and competitive game features.

The product is intentionally lean on cost: the client, auth, sync, static hosting, and the game API all run on **free-tier** services, with engineering choices shaped around those limits.

---

## Product surface

- **Pokédex** — full list with National Dex numbers, sprites, types; search; filters by type and generation
- **Detail profiles** — stats, abilities, height/weight, weaknesses, evolution, localized flavor text, cries, sprite variants
- **Regions** — browse Pokémon by region
- **Favorites** — heart to save; requires an account; synced via Firestore
- **Guest mode** — full browsing without login; auth prompted only when needed
- **Offline-friendly cache** — recently loaded data remains available when connectivity drops
- **Localization** — Portuguese and English (UI + PokéAPI game text when available)
- **Guess the Pokémon** — silhouette/quiz game with local play and optional authenticated competitive mode (leaderboards, publish score)
- **Account & legal** — profile, password/email flows, terms/privacy, account-deletion path for Play Data Safety

---

## Architecture

The app follows a **feature-first** layout with clear boundaries inspired by clean architecture.

```text
lib/
  core/          # bootstrap, router, network, Drift DB, Firebase, locale, theme
  features/      # auth, pokemon, regions, favorites, guess_the_pokemon, …
    <feature>/
      domain/        # entities, repository contracts, policies
      data/          # datasources, mappers, repository implementations
      presentation/  # pages, widgets, Riverpod providers/controllers
  shared/        # reusable UI
  l10n/          # ARB + generated localizations
```

**State & navigation:** Riverpod for dependency injection and UI state; `go_router` for typed routes, auth redirects, and shell navigation.

### Pokédex data flow

```text
UI (Riverpod)
    → PokemonRepository
        → Remote (PokéAPI via Dio)
        → Local cache (Drift)
    → entities → presentation
```

Remote responses are mapped into domain entities and persisted locally so list/detail browsing stays responsive and degrades gracefully offline. Locale changes rebuild localized name indexes and game-text caches.

### Auth & favorites

| Concern | Approach |
|---------|----------|
| Identity | Firebase Authentication |
| Email/password | All platforms (web + mobile) |
| Google Sign-In | **Mobile only** (see [Decisions](#design-decisions--tradeoffs)) |
| Guest | Allowed for Pokédex/regions; no persistent favorites |
| Favorites | `users/{uid}/favorites/{pokemonId}` in Cloud Firestore after login |

Release builds require Firebase configuration. Debug can fall back to a local mock auth path for development convenience.

### Guess the Pokémon

Two modes share one feature module:

| Mode | Behavior |
|------|----------|
| **Local** | Bundled catalog (`assets/game/catalog-v1.json`); scores stay on device |
| **Competitive** | Cloudflare Worker + D1; Firebase ID token on mutations; leaderboards and publish |

The Worker serves gameplay from a **checked-in catalog** (validated at build time). It does **not** call PokéAPI at request time — important for free-tier request/row budgets and for deterministic sessions. Rate limits apply per user and IP (session starts, answers, publishes).

```text
Flutter client
    → local catalog / best score (SharedPreferences + assets)
    → optional GAME_API_BASE_URL
        → Worker (/v1/game, /v1/leaderboards, /v1/me/…)
            → D1 (sessions, scores, rate-limit buckets)
            → Firebase token verification
```

### Hosting topology (high level)

| Piece | Role |
|-------|------|
| Flutter Android | Play Store distribution |
| Flutter Web (Wasm + JS fallback) | Cloudflare Pages (`pokedata.kaique.site`) |
| Firebase Auth + Firestore | Identity, favorites, legal documents |
| Cloudflare Worker + D1 | Competitive game API |
| GitHub Actions | Analyze, test, web/Worker deploy, Android AAB upload, free-tier usage monitor |

---

## Tech stack

| Layer | Choice |
|-------|--------|
| Client | Flutter 3.47+ / Dart 3.13+, Material, Poppins |
| State | Riverpod 3 |
| Routing | go_router |
| Local DB | Drift |
| HTTP | Dio (+ offline/retry guards) |
| Auth / sync | Firebase Auth, Cloud Firestore |
| Analytics | Firebase Analytics |
| Game API | Cloudflare Workers, D1 |
| Web runtime | Wasm (skwasm multi-thread) with JS fallback |
| CI | GitHub Actions |
| Quality | `very_good_analysis`, extensive unit/widget tests |

---

## Design decisions & tradeoffs

### WebAssembly multi-thread vs Google Sign-In on web

Production web enables **cross-origin isolation** (COOP / COEP) so Flutter’s Wasm renderer can use **SharedArrayBuffer** and multi-threaded skwasm. That isolation is incompatible with Firebase’s Google Auth helpers in the browser.

**Decision:** keep Wasm multi-thread for web performance; offer **email/password** on web; keep **Google Sign-In on Android** (and Apple Sign-In where applicable on mobile). Same product, platform-appropriate auth surface — not an unfinished feature.

### Free-tier by design

The stack is chosen so a real published product can run at **$0** infrastructure cost:

- Firebase Spark (Auth + Firestore for favorites/legal)
- Cloudflare Pages (static Flutter web)
- Workers + D1 (game API within daily free ceilings)
- GitHub Actions for CI/CD

**Consequences:** conservative Worker rate limits; catalog baked into the Worker; a scheduled job that warns/fails when Workers/D1 usage approaches free ceilings; competitive mode optional (client works in local mode if the API URL is unset).

### Guest-first Pokédex, account for persistence

Browsing must work without friction. Favorites and competitive identity need a stable `uid`, so those paths gate on sign-in (with a clear prompt rather than a hard wall on first open).

### Cache-first Pokémon data

PokéAPI is the source of truth for species data; Drift is the offline and performance layer. Tradeoff: cached entries can lag until refreshed — acceptable for a reference app, and better UX on flaky networks.

### Dual game modes in one feature

Local mode proves the UX without backend dependency. Competitive mode adds fairness (server-side sessions), leaderboards, and anti-abuse caps. Shared domain types keep the UI consistent across both.

### Android first; iOS later

Production shipping target is Android (Play Store) plus Web. **iOS is a planned future platform**, not abandoned — the Flutter codebase is the foundation for that expansion.

---

## Constraints & known limitations

- **Google Sign-In is not available on web** while Wasm multi-thread (COOP/COEP) remains enabled
- **Layout is mobile-first** — wide desktop viewports stretch some detail layouts; best experience is a phone-width viewport or the Android app
- **iOS** — not in the current production release track (roadmap item)
- **Fan project** — PokéAPI data may change as that upstream project updates
- Free-tier ceilings require ongoing awareness (monitor + rate limits); growth may eventually force paid plans or further optimizations

---

## Engineering strengths

- **Shipped product** — live on [Google Play](https://play.google.com/store/apps/details?id=com.kaiquesimao.pokedex) and [web](https://pokedata.kaique.site)
- **Clear modular architecture** — features isolated with domain contracts and testable data/presentation layers
- **Broad automated tests** — domain, repositories, providers, and widget coverage across auth, Pokédex, game, and core networking
- **Production web Wasm** — multi-thread renderer with JS fallback for browsers without WasmGC
- **CI/CD** — analyze + test on every push/PR; web and Worker deploy from `master`; signed AAB upload to Play open testing on version bumps
- **Free-tier discipline** — usage monitor against Workers/D1 daily limits; game API designed not to hammer PokéAPI at runtime
- **Play compliance** — in-app legal docs, account-deletion URL for Data Safety, in-app review hooks
- **i18n** — PT/EN app strings and localized PokéAPI text resolution

---

## Roadmap

- **iOS** release track (parity with Android auth and store requirements)
- Continued game and Pokédex quality-of-life improvements within free-tier constraints

---

## Disclaimer

PokeData is a **fan-made** project. It is not developed, endorsed, or affiliated with Nintendo, The Pokémon Company, Game Freak, or Creatures Inc. Pokémon and Pokémon character names are trademarks of their respective owners. Species data is sourced from [PokéAPI](https://pokeapi.co/).
