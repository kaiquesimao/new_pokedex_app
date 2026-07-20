# Pokédex

Explore todos os Pokémon, regiões e favoritos — sua Pokédex completa.

Flutter app targeting **Android** and **Web** (mobile-first).

## Prerequisites

- Flutter SDK (stable)
- Firebase project with Authentication and Cloud Firestore
- Local secret files (not in git):
  - `dart_defines.json` — copy from [`dart_defines.example.json`](dart_defines.example.json)
  - `android/app/google-services.json` — copy from [`android/app/google-services.example.json`](android/app/google-services.example.json)

See [`lib/core/firebase/README.md`](lib/core/firebase/README.md) for Firebase setup details.

## Run locally

Configs in [`.vscode/launch.json`](.vscode/launch.json) pass `--dart-define-from-file=dart_defines.json`.

```bash
flutter pub get
flutter run --dart-define-from-file=dart_defines.json
```

Web (port 5000):

```bash
flutter run -d chrome --web-port=5000 --dart-define-from-file=dart_defines.json
```

Guest browsing: on the welcome screen tap **Explorar sem conta** to use the Pokédex without logging in.

## Production builds

Always pass Firebase compile-time defines:

```bash
# Android (Play Store)
flutter build appbundle --release --dart-define-from-file=dart_defines.json

# Web (Wasm + JS fallback)
flutter build web --release --wasm \
  --dart-define-from-file=dart_defines.json
```

### Google Play — account deletion URL

`https://pokedata.kaique.site/#/legal/account-deletion`

Data Safety → account deletion link. Optional “delete data without deleting
account”: No.

Optional Android obfuscation:

```bash
flutter build appbundle --release \
  --dart-define-from-file=dart_defines.json \
  --obfuscate --split-debug-info=build/debug-info
```

### Android signing

1. Generate a release keystore (keep a secure backup).
2. Copy [`android/key.properties.example`](android/key.properties.example) to `android/key.properties` (gitignored).
3. Point `storeFile` to your `.jks` file.
4. Add **SHA-1** and **SHA-256** of the release keystore in Firebase Console, then re-download `google-services.json`.

```bash
cd android && ./gradlew signingReport
```

**Application ID:** `com.kaiquesimao.pokedex`

### Web auth

Web supports **email/password** Firebase Auth. Google Sign-In is **mobile only**
— Wasm multi-thread (COOP: same-origin + COEP: credentialless in
[web/_headers](web/_headers)) is incompatible with Firebase Google Auth helpers.

| Setup | Wasm | Email/password | Google |
|-------|------|----------------|--------|
| Production (COOP/COEP) | ✅ multi-thread | ✅ | ❌ web / ✅ mobile |
| Local **Chrome Wasm MT :5000** (--wasm) | ✅ multi-thread | ✅ | ❌ web / ✅ mobile |

`ash
flutter run -d chrome --web-port=5000 \
  --dart-define-from-file=dart_defines.json \
  --wasm
`

Mobile still uses google_sign_in + GoogleSignIn.authenticate.

FIREBASE_GOOGLE_WEB_CLIENT_ID remains required in dart_defines.json as
Android serverClientId.

### WebAssembly (multi-thread)

CI builds with --wasm. Production headers enable SharedArrayBuffer.

### Cloudflare zone (required for custom domain)

pokedata.kaique.site is served through your **kaique.site** zone. Keep
**Rocket Loader** and **Bot Fight Mode** off for this host — both break Flutter
on the custom domain (not on *.pages.dev).

## CI / CD (web → Cloudflare Pages)

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) + Dependabot
([`.github/dependabot.yml`](.github/dependabot.yml)):

| Trigger | What runs |
|---------|-------------|
| Every push / PR | `flutter analyze` + `flutter test` |
| Push to `master` | `flutter build web --wasm` → deploy **production** → smoke checks |
| PR (same repo) | Same Wasm build → Cloudflare **preview** (`pr-<number>`) → comment URL on the PR |

Production URL: **https://pokedata.kaique.site**

SPA deep links use [`web/_redirects`](web/_redirects). Headers: [`web/_headers`](web/_headers).
Web build artifacts are uploaded (7-day retention) for failed-deploy debugging.

### GitHub Secrets (required)

| Secret | Purpose |
|--------|---------|
| `DART_DEFINES_JSON` | Full contents of `dart_defines.json` (same shape as [`dart_defines.example.json`](dart_defines.example.json)) |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token with **Account → Cloudflare Pages → Edit** |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare account ID |

Optional:

| Secret | Purpose |
|--------|---------|
| `CLOUDFLARE_PROJECT_NAME` | Pages project name (default: `pokedata`) |

Do **not** commit real `dart_defines.json` or Cloudflare credentials.

### One-time setup (manual)

1. **Cloudflare Pages:** create a project (name `pokedata` unless you set
   `CLOUDFLARE_PROJECT_NAME`). Direct Upload / Wrangler is enough — GitHub
   Actions owns the build; you do not need a second Pages Git integration.
2. **Custom domain:** attach `pokedata.kaique.site` to that Pages project
   (Cloudflare Dashboard → Pages → Custom domains). DNS: CNAME `pokedata` →
   `pokedata-5fq.pages.dev` (proxied). This is **Pages**, not a Worker route
   (Workers are for apps like a portfolio Worker — Flutter web stays on Pages).
3. **GitHub Secrets:** add the secrets above
   (Settings → Secrets and variables → Actions).
4. **GitHub Environment:** create Environment `production`
   (Settings → Environments). Optional: add required reviewers for deploy.
   Repo secrets still work; moving secrets into the environment is optional.
5. **Firebase Auth:** add `pokedata.kaique.site` under
   Authentication → Settings → Authorized domains.
   PR preview URLs (`*.pages.dev`) also need the Pages domain(s) if you test
   Google Sign-In on previews — add those hostnames as needed.

## Verify

```bash
flutter analyze
flutter test
```

## Version

App version is defined in [`pubspec.yaml`](pubspec.yaml) (`version: x.y.z+build`) and shown in Profile via `package_info_plus`.
