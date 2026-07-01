---
description: 
alwaysApply: false
---

# AGENTS.md

## Cursor Cloud specific instructions

This is a **Flutter Pokédex app** (`pokedex_app`), mobile-first but also targets web.
In this Linux cloud VM the testable target is the **web** build (Chrome is installed at
`/usr/local/bin/google-chrome`).

### Toolchain (already provisioned in the VM snapshot)

- Flutter SDK is preinstalled at `$HOME/flutter` (Flutter 3.44.2 / Dart 3.12.2, stable) and is
  on `PATH` via `~/.bashrc`. If `flutter` is not found in a non-interactive shell, call it
  directly: `"$HOME/flutter/bin/flutter"`.
- The startup update script runs `flutter pub get`; dependencies are otherwise ready.

### Run / lint / test / build (web)

- Run (dev): `flutter run -d web-server --web-port 5000 --web-hostname 0.0.0.0`, then open
  `http://localhost:5000` in a browser. `-d chrome` also works. See `.vscode/launch.json`.
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
