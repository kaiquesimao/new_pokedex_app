# Adaptive Native TTS Quality Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Pokémon description speech use the best compatible native Android/iOS voice and a natural quality profile without adding paid services.

**Architecture:** Keep `PokemonDescriptionTtsNotifier` as the lifecycle and playback owner. Extract voice ranking into a pure selector so locale matching, quality ordering, network preference, malformed metadata, and deterministic ties can be tested without a native engine. Apply the selected voice and quality profile opportunistically, preserving the existing language and speech fallbacks.

**Tech Stack:** Flutter 3.47, Dart 3.13, `flutter_tts` 4.2.5, Riverpod 3, `flutter_test`.

## Global Constraints

- Use only voices exposed by the native Android/iOS TTS engine; do not add voice downloads, bundled models, cloud providers, or new dependencies.
- Preserve the existing `PokemonDescriptionTtsNotifier` public API and play/stop/error behavior.
- Keep all production code in English and follow existing `very_good_analysis` conventions.
- Voice discovery or selection failures must not block `setLanguage` and `speak`.
- Verification must include focused tests, `flutter analyze`, and the complete `flutter test` suite.

---

### Task 1: Add a deterministic native voice selector

**Files:**
- Create: `lib/features/pokemon/presentation/providers/pokemon_tts_voice_selector.dart`
- Test: `test/features/pokemon/presentation/providers/pokemon_tts_voice_selector_test.dart`

**Interfaces:**
- Produces `PokemonTtsVoiceSelector.select({required List<dynamic> voices, required AppLocale locale})`, returning `Map<String, String>?`.
- The returned map contains `{name, locale}` for Android-compatible metadata, or `{identifier}` when an iOS identifier is the only usable voice identity.
- Consumes `AppLocale.pt` and `AppLocale.en` plus the `flutter_tts` voice maps documented as containing `name`, `locale`, optional `quality`, `network_required`, and optional `identifier`.

- [ ] **Step 1: Write the failing selector tests**

Create a test file that exercises these behaviors:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_tts_voice_selector.dart';

void main() {
  test('prefers an exact locale over a higher-quality language fallback', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.pt,
      voices: [
        {'name': 'English Premium', 'locale': 'en-US', 'quality': 500},
        {'name': 'Portuguese Default', 'locale': 'pt-BR', 'quality': 100},
      ],
    );

    expect(result, {'name': 'Portuguese Default', 'locale': 'pt-BR'});
  });

  test('prefers the highest-quality voice within the same locale', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.en,
      voices: [
        {'name': 'English Basic', 'locale': 'en-US', 'quality': 100},
        {'name': 'English Enhanced', 'locale': 'en-US', 'quality': 500},
      ],
    );

    expect(result, {'name': 'English Enhanced', 'locale': 'en-US'});
  });

  test('prefers a non-network voice when quality is tied', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.en,
      voices: [
        {
          'name': 'English Online',
          'locale': 'en-US',
          'quality': 500,
          'network_required': true,
        },
        {
          'name': 'English Offline',
          'locale': 'en-US',
          'quality': 500,
          'network_required': false,
        },
      ],
    );

    expect(result, {'name': 'English Offline', 'locale': 'en-US'});
  });

  test('ignores malformed voices and uses a stable name tie-breaker', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.en,
      voices: [
        {'locale': 'en-US', 'quality': 500},
        {'name': 'Zulu', 'locale': 'en-US', 'quality': 100},
        {'name': 'Alpha', 'locale': 'en-US', 'quality': 100},
      ],
    );

    expect(result, {'name': 'Alpha', 'locale': 'en-US'});
  });

  test('uses an iOS identifier when name and locale are unavailable', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.pt,
      voices: [
        {
          'identifier': 'com.apple.voice.enhanced.pt-BR.Test',
          'locale': 'pt-BR',
          'quality': 2,
        },
      ],
    );

    expect(result, {
      'identifier': 'com.apple.voice.enhanced.pt-BR.Test',
    });
  });

  test('returns null when no voice matches the requested language', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.pt,
      voices: [
        {'name': 'English', 'locale': 'en-US', 'quality': 500},
      ],
    );

    expect(result, isNull);
  });
}
```

- [ ] **Step 2: Run the focused test and verify the expected red failure**

Run:

```bash
flutter test test/features/pokemon/presentation/providers/pokemon_tts_voice_selector_test.dart
```

Expected: the test fails because `pokemon_tts_voice_selector.dart` and
`PokemonTtsVoiceSelector.select` do not yet exist.

- [ ] **Step 3: Implement the minimal selector**

Implement the selector as a stateless utility. Normalize locale values by
replacing `_` with `-` and comparing case-insensitively. Rank valid maps by
exact-locale match, language-code match, numeric quality, non-network status,
and lexicographic name/identifier. Accept numeric strings and booleans in
platform metadata, discard entries without a usable identity and locale, and
return only the fields needed by `setVoice`.

- [ ] **Step 4: Run the focused test and verify green**

Run the same focused test command. Expected: all selector tests pass.

- [ ] **Step 5: Commit the selector unit**

```bash
git add lib/features/pokemon/presentation/providers/pokemon_tts_voice_selector.dart \
  test/features/pokemon/presentation/providers/pokemon_tts_voice_selector_test.dart
git commit -m "feat: rank native TTS voices by locale and quality"
```

### Task 2: Apply the quality profile and selector in the provider

**Files:**
- Modify: `lib/features/pokemon/presentation/providers/pokemon_description_tts_provider.dart:15-99`
- Modify: `test/features/pokemon/presentation/providers/pokemon_description_tts_provider_test.dart`
- Preserve: `test/features/pokemon/presentation/widgets/pokemon_detail_about_section_test.dart`

**Interfaces:**
- Consumes `PokemonTtsVoiceSelector.select` from Task 1.
- Keeps `speak({required String text, required AppLocale locale})`,
  `stop()`, and `toggle({required String text, required AppLocale locale})`
  unchanged.
- Applies `setSpeechRate(0.45)`, `setVolume(1.0)`, and `setPitch(1.0)` once
  during initialization.

- [ ] **Step 1: Extend the provider tests with the quality-profile contract**

Add a pure profile assertion alongside the existing notifier tests, using the
production constants exposed by a small immutable profile type:

```dart
test('uses the natural high-quality speech profile', () {
  expect(PokemonTtsQualityProfile.speechRate, 0.45);
  expect(PokemonTtsQualityProfile.volume, 1.0);
  expect(PokemonTtsQualityProfile.pitch, 1.0);
});
```

The provider test file must import the profile symbol from
`pokemon_description_tts_provider.dart`. Keep the existing idle, speaking,
stop, and toggle tests unchanged.

- [ ] **Step 2: Run the provider tests and verify the expected red failure**

Run:

```bash
flutter test test/features/pokemon/presentation/providers/pokemon_description_tts_provider_test.dart
```

Expected: the new profile test fails because the profile constants do not yet
exist; the existing notifier tests continue to pass.

- [ ] **Step 3: Implement initialization and per-utterance voice selection**

Add an immutable `PokemonTtsQualityProfile` with the three constants above.
During `_ensureInitialized`, await the existing completion setup, apply
`setSpeechRate`, `setVolume`, and `setPitch`, and on iOS attempt
`setSharedInstance(true)` plus the documented audio category configuration.
Platform-specific setup must be wrapped so unsupported platforms or native
errors do not prevent speech.

After `_resolveLanguage` and before updating the speaking state, call
`getVoices`, pass the result to `PokemonTtsVoiceSelector.select`, and attempt
`setVoice` only when a selection is returned. Catch voice enumeration and
selection errors separately from the existing `speak` error handling. Always
retain the resolved `setLanguage` call and current state transitions.

- [ ] **Step 4: Run provider and widget tests**

Run:

```bash
flutter test \
  test/features/pokemon/presentation/providers/pokemon_description_tts_provider_test.dart \
  test/features/pokemon/presentation/widgets/pokemon_detail_about_section_test.dart
```

Expected: all tests pass, including unchanged play/stop widget behavior.

- [ ] **Step 5: Run repository verification**

Run:

```bash
flutter analyze
flutter test
```

Expected: analysis reports no issues and the complete test suite passes.

- [ ] **Step 6: Commit the provider integration**

```bash
git add lib/features/pokemon/presentation/providers/pokemon_description_tts_provider.dart \
  test/features/pokemon/presentation/providers/pokemon_description_tts_provider_test.dart
git commit -m "feat: apply adaptive native TTS quality settings"
```

## Final Device Verification

On an Android or iOS emulator/device with the app's language voice installed,
open a Pokémon detail page and play the description in Portuguese and English.
Confirm that playback remains functional, uses the selected native voice, and
falls back to the platform default when voice selection is unavailable. The
Linux web target can validate compilation and existing UI behavior, but cannot
prove Android/iOS voice quality.
