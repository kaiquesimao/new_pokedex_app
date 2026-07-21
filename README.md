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

1. Generate an upload keystore (keep a secure backup — never commit it):

   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Copy [`android/key.properties.example`](android/key.properties.example) to
   `android/key.properties` (gitignored) and fill passwords / alias / `storeFile`.
3. Add **SHA-1** and **SHA-256** in Firebase Console for:
   - Play **app signing** key (Play Console → App signing)
   - **Upload** key (`./gradlew signingReport` or after first AAB upload)
4. Re-download `google-services.json`.

```bash
cd android && ./gradlew signingReport
```

**Application ID:** `com.kaiquesimao.pokedex`

Play Console uses **Play App Signing** (Google holds the distribution key). Your
local/CI `.jks` is only the **upload** key.

### Web auth

Web supports **email/password** Firebase Auth. Google Sign-In is **mobile only**
— Wasm multi-thread (COOP: same-origin + COEP: credentialless in
[web/_headers](web/_headers)) is incompatible with Firebase Google Auth helpers.

| Setup | Wasm | Email/password | Google |
|-------|------|----------------|--------|
| Production (COOP/COEP) | ✅ multi-thread | ✅ | ❌ web / ✅ mobile |
| Local **Chrome Wasm MT :5000** (--wasm) | ✅ multi-thread | ✅ | ❌ web / ✅ mobile |

```bash
flutter run -d chrome --web-port=5000 \
  --dart-define-from-file=dart_defines.json \
  --wasm
```

Mobile still uses google_sign_in + GoogleSignIn.authenticate.

FIREBASE_GOOGLE_WEB_CLIENT_ID remains required in dart_defines.json as
Android serverClientId.

### WebAssembly (multi-thread)

CI builds with --wasm. Production headers enable SharedArrayBuffer.

### Cloudflare zone (required for custom domain)

pokedata.kaique.site is served through your **kaique.site** zone. Keep
**Rocket Loader** and **Bot Fight Mode** off for this host — both break Flutter
on the custom domain (not on *.pages.dev).

## CI / CD

Dependabot: [`.github/dependabot.yml`](.github/dependabot.yml).

### Web → Cloudflare Pages

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) (**CI Web**):

| Trigger | What runs |
|---------|-------------|
| Every push / PR | `flutter analyze` + `flutter test` |
| Push to `master` | `flutter build web --wasm` → deploy **production** → smoke checks |
| PR (same repo) | Same Wasm build → Cloudflare **preview** (`pr-<number>`) → comment URL on the PR |

Production URL: **https://pokedata.kaique.site**

SPA deep links use [`web/_redirects`](web/_redirects). Headers: [`web/_headers`](web/_headers).
Web build artifacts are uploaded (7-day retention) for failed-deploy debugging.

### Android → Play Store (internal testing)

[`.github/workflows/release-android.yml`](.github/workflows/release-android.yml):

| Trigger | What runs |
|---------|-------------|
| Tag `v*` (e.g. `v1.0.1`) | analyze → test → signed AAB → upload **internal** track |
| Manual (`workflow_dispatch`) | Same; choose track (`internal` / `alpha` / `beta`) and whether to upload |

Before tagging, bump `version:` in [`pubspec.yaml`](pubspec.yaml)
(`x.y.z+build` — **build** / `versionCode` must increase every Play upload).

```bash
# After bumping pubspec version:
git tag v1.0.1
git push origin v1.0.1
```

Or: Actions → **Release Android** → Run workflow (upload optional for build-only).

### GitHub Secrets

**Web (required):**

| Secret | Purpose |
|--------|---------|
| `DART_DEFINES_JSON` | Full contents of `dart_defines.json` (same shape as [`dart_defines.example.json`](dart_defines.example.json)) |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token with **Account → Cloudflare Pages → Edit** |
| `CLOUDFLARE_ACCOUNT_ID` | Cloudflare account ID |

**Android release (required for `release-android.yml`):**

| Secret | Purpose |
|--------|---------|
| `DART_DEFINES_JSON` | Same as web |
| `GOOGLE_SERVICES_JSON` | Full contents of `android/app/google-services.json` |
| `KEYSTORE_BASE64` | Base64 of `android/upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | Keystore store password |
| `KEY_PASSWORD` | Key password (often same as store) |
| `KEY_ALIAS` | Key alias (e.g. `upload`) |
| `PLAY_SERVICE_ACCOUNT_JSON` | Play Console API service account JSON |

Encode the keystore (PowerShell):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\upload-keystore.jks")) |
  Set-Clipboard
```

Optional:

| Secret | Purpose |
|--------|---------|
| `CLOUDFLARE_PROJECT_NAME` | Pages project name (default: `pokedata`) |

Do **not** commit `dart_defines.json`, `google-services.json`, keystores, or API keys.

### One-time setup (manual)

**Web**

1. **Cloudflare Pages:** create a project (name `pokedata` unless you set
   `CLOUDFLARE_PROJECT_NAME`). Direct Upload / Wrangler is enough — GitHub
   Actions owns the build; you do not need a second Pages Git integration.
2. **Custom domain:** attach `pokedata.kaique.site` to that Pages project
   (Cloudflare Dashboard → Pages → Custom domains). DNS: CNAME `pokedata` →
   `pokedata-5fq.pages.dev` (proxied). This is **Pages**, not a Worker route
   (Workers are for apps like a portfolio Worker — Flutter web stays on Pages).
3. **GitHub Secrets:** add the web secrets above
   (Settings → Secrets and variables → Actions).
4. **GitHub Environment:** create Environment `production`
   (Settings → Environments). Optional: add required reviewers for deploy.
   Repo secrets still work; moving secrets into the environment is optional.
5. **Firebase Auth:** add `pokedata.kaique.site` under
   Authentication → Settings → Authorized domains.
   PR preview URLs (`*.pages.dev`) also need the Pages domain(s) if you test
   Google Sign-In on previews — add those hostnames as needed.

**Android / Play**

1. Upload at least one AAB manually (Internal testing) so the package exists
   and Play App Signing is active.
2. Google Cloud → enable **Google Play Android Developer API** → create a
   **service account** (no GCP roles) → JSON key → invite that email in
   Play Console → Users and permissions (release access to this app).
3. Add the Android secrets above in GitHub.
4. Firebase: SHA-1/SHA-256 of app signing + upload keys (see Android signing).

## Verify

```bash
flutter analyze
flutter test
```

## Version

App version is defined in [`pubspec.yaml`](pubspec.yaml) (`version: x.y.z+build`) and shown in Profile via `package_info_plus`.
