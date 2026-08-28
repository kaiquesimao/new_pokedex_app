# Firebase setup

The app bootstraps Firebase on startup when compile-time config is available.
Favorites sync to Firestore after login; local cache remains the offline source.

## Prerequisites

1. Firebase project with **Authentication** (email/password, Google) and **Cloud Firestore**.
2. Local secret files (gitignored):
   - `dart_defines.json` — copy from `dart_defines.example.json` at project root
   - `android/app/google-services.json` — copy from `android/app/google-services.example.json`

## Configuration model

Firebase credentials are **not** embedded in `lib/firebase_options.dart`. They are injected at build time:

| File | Role |
|------|------|
| `dart_defines.json` | Values for `FIREBASE_*` keys (see `dart_defines.example.json`) |
| `lib/core/env/env.dart` | Reads `String.fromEnvironment('FIREBASE_*')` |
| `lib/firebase_options.dart` | Builds `FirebaseOptions` from `Env` |
| `lib/core/firebase/firebase_bootstrap.dart` | Calls `Firebase.initializeApp` when configured |

Build/run **must** include:

```bash
--dart-define-from-file=dart_defines.json
```

Release builds without `FIREBASE_PROJECT_ID` show a configuration error screen (no mock auth fallback).

## Bootstrap

1. `lib/core/env/env.dart` — compile-time Firebase keys.
2. `lib/firebase_options.dart` — platform options from `Env`.
3. `lib/core/firebase/firebase_bootstrap.dart` — `Firebase.initializeApp`.
4. `lib/core/bootstrap/app_bootstrap.dart` — cold start (connectivity, Firebase, prefs, auth).
5. `main.dart` — splash, cold start, then `PokedexApp`.

## Platform files

- **Android:** `android/app/google-services.json` (Gradle plugin `com.google.gms.google-services`).
- **iOS:** out of scope for current production target.

**Android application ID:** `com.kaiquesimao.pokedex`

## Firestore paths

### Favorites

`users/{uid}/favorites/{pokemonId}` — fields: `pokemonId` (int), `addedAt` (timestamp).

### Legal documents

`legal_documents/{docId}` — public read when `published == true`.

| docId | slug | locale |
|-------|------|--------|
| `terms_pt_BR` | `terms` | `pt_BR` |
| `terms_en` | `terms` | `en` |
| `privacy_pt_BR` | `privacy` | `pt_BR` |
| `privacy_en` | `privacy` | `en` |
| `account_deletion_pt_BR` | `account_deletion` | `pt_BR` |
| `account_deletion_en` | `account_deletion` | `en` |

Fields: `slug`, `locale`, `markdown`, `version`, `updatedAt`, `published`.

Seed from bundled assets (uses `firebase login` credentials):

```bash
cd scripts && npm install && cd ..
firebase deploy --only firestore:rules
node scripts/seed_legal_documents.cjs
```

The app falls back to bundled `assets/legal/*.md` when Firestore is unavailable.

Deploy rules:

```bash
firebase login
firebase deploy --only firestore:rules
```

Project default: `pokedex-app-c5e90` (`.firebaserc`).

## Google Sign-In (Android)

1. Add **SHA-1** and **SHA-256** in Firebase Console → Project settings → Android app (`com.kaiquesimao.pokedex`).

```bash
cd android && ./gradlew signingReport
```

2. **Re-download** `google-services.json` after adding fingerprints. The file must include an `oauth_client` with `"client_type": 1` (Android).

3. The app uses the Web client ID as `serverClientId` in `FirebaseAuthConfig` (required for Firebase Auth idToken on Android).

4. **Web:** Google Sign-In is not offered (Wasm COOP/COEP). Use email/password on web.

5. Rebuild after replacing config files:

```bash
flutter clean && flutter run --dart-define-from-file=dart_defines.json
```

## Auth behavior

| Flow | Firebase configured | Debug without Firebase |
|------|---------------------|------------------------|
| Email login/signup | `FirebaseAuth` | SharedPreferences (dev only) |
| Email verification | Link + reload | 6-digit OTP (dev only) |
| Password reset | `sendPasswordResetEmail` | OTP flow (dev only) |
| Change password | reauth + `updatePassword` | local store (dev only) |
| Google (mobile) | OAuth credentials | Hidden |
| Google (web) | Not available | Hidden |
| Guest browsing | Allowed (`/pokedex` without login) | Allowed |

Release builds require Firebase; mock auth is disabled in `kReleaseMode`.
