# Adaptive Native TTS Quality Design

## Goal

Improve the Pokémon description TTS quality on Android and iOS without introducing
cloud costs, while preserving the existing play/stop UI and graceful language
fallback behavior.

## Scope

- Configure a natural speech profile with full volume, neutral pitch, and a
  deliberately moderate speech rate.
- Discover voices exposed by `flutter_tts` on Android and iOS.
- Prefer an exact application locale (`pt-BR` or `en-US`) and the highest-quality
  voice reported by the platform.
- Fall back to the best available language voice, then to the current language
  fallback behavior when voice discovery or selection fails.
- Configure iOS audio session behavior without disrupting other app audio more
  than necessary.
- Keep the provider API and existing widget behavior unchanged.

Out of scope:

- Downloading or bundling voice data.
- Replacing native TTS with a cloud provider.
- Adding user-facing voice settings.
- Changing the Pokémon description text or localization flow.

## Architecture

`PokemonDescriptionTtsNotifier` remains the single owner of the `FlutterTts`
instance and its lifecycle. Initialization will apply the platform-safe global
settings once. Before each utterance, the notifier will resolve the requested
language and select a voice from `getVoices` when the platform exposes voice
metadata.

Voice ranking will be deterministic:

1. Exact locale match.
2. Same language-code match.
3. Higher platform-reported quality.
4. Android voices that do not require network access only when quality is tied;
   network-backed voices remain eligible because they can provide higher quality.
5. Stable name/identifier ordering as a final tie-breaker.

The selected voice will be passed through `setVoice` using only the fields
supported by the platform. If no valid voice can be selected, `setLanguage` will
still be applied and speech will continue with the platform default voice.

## Data Flow

1. `speak` trims and rejects empty text as it does today.
2. The provider initializes the engine and applies the quality profile.
3. It resolves the best available language.
4. It retrieves and ranks voices for that language.
5. It attempts to apply the selected voice, ignoring selection-specific failures.
6. It updates the speaking state and calls `speak`.
7. Existing completion, cancel, error, stop, and disposal paths remain active.

## Error Handling

Voice enumeration and voice selection are enhancements, not prerequisites for
speech. Platform exceptions or malformed voice metadata must not prevent the
fallback `setLanguage`/`speak` flow. Existing speaking error state behavior remains
unchanged for failures from the actual speech call.

## Testing

- Add focused tests for voice ranking: exact locale, language fallback, quality
  ordering, network tie-breaking, malformed entries, and stable tie-breaking.
- Test the quality profile values through a small injectable configuration or
  equivalent provider seam, without requiring a real Android/iOS engine.
- Preserve and run the existing notifier and widget tests for play/stop behavior.
- Run `flutter analyze` and the complete `flutter test` suite.
- Manually verify on a physical or emulator Android/iOS device when a native
  TTS engine and enhanced voices are available; web validation cannot prove
  native voice quality.

## Acceptance Criteria

- Android and iOS use the highest-quality compatible installed voice when voice
  metadata is available.
- The app still speaks when no preferred voice is installed or voice discovery
  fails.
- Speech uses full volume, neutral pitch, and a natural moderate rate.
- Existing language fallback and play/stop/error behavior remain intact.
- No new paid service, secret, or runtime network dependency is introduced.
