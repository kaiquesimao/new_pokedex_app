---
description: 
alwaysApply: false
---

# AGENTS.md

## Cursor Cloud specific instructions

This is a **Flutter Pokédex app** (`pokedex_app`), mobile-first but also targets web.
In this Linux cloud VM the testable target is the **web** build (Chrome is installed at
`/usr/local/bin/google-chrome`).

### Toolchain

- `.cursor/install.sh` installs Flutter 3.47 (Dart 3.13+) into `$HOME/flutter` and wrappers
  at `/usr/local/bin/flutter` and `/usr/local/bin/dart`, so login shells find them without
  `~/.bashrc`. It also runs `flutter pub get` and `npm ci` for the Guess the Pokémon Worker.
- Node.js 22 is linked on `/usr/local/bin` when the base image provides it via nvm.
- Chrome is at `/usr/local/bin/google-chrome`.
- On every boot, `.cursor/start.sh` runs the Flutter web server on `0.0.0.0:5000` (idempotent
  if that process is already up). First compile can take a few minutes; readiness is HTTP
  on port 5000. Logs: `/tmp/cursor/start-user/start-user.log`.

### Run / lint / test / build (web)

- Run (dev): `flutter run -d web-server --web-port 5000 --web-hostname 0.0.0.0`, then open
  `http://localhost:5000` in a browser. The boot `start` script already does this. `-d chrome`
  also works. See `.vscode/launch.json`.
- Lint: `flutter analyze` (note `analysis_options.yaml` treats `deprecated_member_use` as an error).
- Test: `flutter test`.
- Build (web): `flutter build web`. A release build served statically
  (`cd build/web && python3 -m http.server <port>`) is much lighter than the debug dev server.

### Non-obvious notes

- **No secrets needed to run.** `lib/firebase_options.dart` is committed; `bootstrapFirebase()`
  degrades gracefully if Firebase is unavailable, and auth has a guest/mock fallback — on the
  welcome screen tap **"Pular" (Skip)** to reach the Pokédex without logging in.
- **Codegen is committed.** drift/`build_runner` outputs (`*.g.dart`, e.g.
  `lib/core/database/app_database.g.dart`) are tracked and up to date. Only re-run
  `dart run build_runner build` after changing drift schemas/models.
- **Full test suite passes:** `flutter test` runs ~131 tests and all pass (verified in the cloud
 VM). The type chip renders its icon as SVG via `SvgPicture.asset`
 (`lib/shared/widgets/pokemon_type_icon.dart`).
- **Favorites require auth:** guest mode ("Explorar sem conta"/"Pular") allows full browsing and
 Pokémon detail pages, but tapping the heart to favorite prompts a sign-in dialog — favoriting
 and the Favorites tab are gated behind an account.
- **Web layout / stability gotchas:** detail-page weight/height cards stretch on wide desktop
  viewports (the layout is mobile-first) — use a narrow/mobile viewport for accurate layout. In
  this constrained browser VM the Flutter web tab can reload (Flutter loading spinner) after
  extended interaction/heavy sprite loading; the release build is more stable than the debug dev
  server.

- **Version on every shipping PR:** before opening/pushing a feature or fix PR, add Play
  changelogs for the next `versionCode` under `store/google_play/*/changelogs/`, then run
  `.\scripts\release.ps1 patch` (or `./scripts/release.sh patch`) on the PR branch to bump
  `pubspec.yaml` and push (**no `v*` tag**). GitHub Release + Play upload happen after merge
  to `master`. See `.cursor/rules/pr-version-bump.mdc`.
