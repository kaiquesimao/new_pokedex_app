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
