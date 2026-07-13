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

# Web
flutter build web --release --dart-define-from-file=dart_defines.json
```

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

### Web Google Sign-In

`FIREBASE_GOOGLE_WEB_CLIENT_ID` in `dart_defines.json` is used at runtime
([`FirebaseAuthConfig`](lib/core/constants/firebase_auth_config.dart)). If you
add a `google-signin-client_id` meta tag in [`web/index.html`](web/index.html),
keep it in sync with that value.

## CI / CD (web → Cloudflare Pages)

On every push/PR, [`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs
`flutter analyze` and `flutter test`. On push to `master` (after CI green), it
builds Flutter web and deploys `build/web` to **Cloudflare Pages** via Wrangler.

Production URL: **https://pokedata.kaique.site**

SPA deep links use [`web/_redirects`](web/_redirects) (copied into `build/web`).

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
   (Cloudflare Dashboard → Pages → Custom domains). DNS for `kaique.site`
   should already be on Cloudflare.
3. **GitHub Secrets:** add the secrets above
   (Settings → Secrets and variables → Actions).
4. **Firebase Auth:** add `pokedata.kaique.site` under
   Authentication → Settings → Authorized domains.

## Verify

```bash
flutter analyze
flutter test
```

## Version

App version is defined in [`pubspec.yaml`](pubspec.yaml) (`version: x.y.z+build`) and shown in Profile via `package_info_plus`.
