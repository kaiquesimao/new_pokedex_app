import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_tts_voice_selector.dart';

void main() {
  test('prefers an exact locale over a higher-quality language fallback', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.pt.tag,
      voices: [
        {'name': 'English Premium', 'locale': 'en-US', 'quality': 500},
        {'name': 'Portuguese Default', 'locale': 'pt-BR', 'quality': 100},
      ],
    );

    expect(result, {'name': 'Portuguese Default', 'locale': 'pt-BR'});
  });

  test('prefers the highest-quality voice within the same locale', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.en.tag,
      voices: [
        {'name': 'English Basic', 'locale': 'en-US', 'quality': 100},
        {'name': 'English Enhanced', 'locale': 'en-US', 'quality': 500},
      ],
    );

    expect(result, {'name': 'English Enhanced', 'locale': 'en-US'});
  });

  test('ranks symbolic platform quality values', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.en.tag,
      voices: [
        {'name': 'English Normal', 'locale': 'en-US', 'quality': 'normal'},
        {'name': 'English Premium', 'locale': 'en-US', 'quality': 'premium'},
      ],
    );

    expect(result, {'name': 'English Premium', 'locale': 'en-US'});
  });

  test('prefers a non-network voice when quality is tied', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.en.tag,
      voices: [
        {
          'name': 'Alpha Online',
          'locale': 'en-US',
          'quality': 500,
          'network_required': true,
        },
        {
          'name': 'Zulu Offline',
          'locale': 'en-US',
          'quality': 500,
          'network_required': false,
        },
      ],
    );

    expect(result, {'name': 'Zulu Offline', 'locale': 'en-US'});
  });

  test('recognizes Android network metadata encoded as one and zero', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.en.tag,
      voices: [
        {
          'name': 'Alpha Online',
          'locale': 'en-US',
          'quality': 'very high',
          'network_required': '1',
        },
        {
          'name': 'Zulu Offline',
          'locale': 'en-US',
          'quality': 'very high',
          'network_required': '0',
        },
      ],
    );

    expect(result, {'name': 'Zulu Offline', 'locale': 'en-US'});
  });

  test('ignores Android voices marked as not installed', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.en.tag,
      voices: [
        {
          'name': 'Alpha Missing',
          'locale': 'en-US',
          'quality': 'very high',
          'features': ['notInstalled'],
        },
        {'name': 'Zulu Installed', 'locale': 'en-US', 'quality': 'high'},
      ],
    );

    expect(result, {'name': 'Zulu Installed', 'locale': 'en-US'});
  });

  test('ignores malformed voices and uses a stable name tie-breaker', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.en.tag,
      voices: [
        {'locale': 'en-US', 'quality': 500},
        {'name': 'Zulu', 'locale': 'en-US', 'quality': 100},
        {'name': 'Alpha', 'locale': 'en-US', 'quality': 100},
      ],
    );

    expect(result, {'name': 'Alpha', 'locale': 'en-US'});
  });

  test('prefers an iOS identifier when it is available', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.pt.tag,
      voices: [
        {
          'name': 'Portuguese Enhanced',
          'identifier': 'com.apple.voice.enhanced.pt-BR.Test',
          'locale': 'pt-BR',
          'quality': 2,
        },
      ],
    );

    expect(result, {
      'name': 'Portuguese Enhanced',
      'locale': 'pt-BR',
      'identifier': 'com.apple.voice.enhanced.pt-BR.Test',
    });
  });

  test('falls back to another region of the requested language', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.pt.tag,
      voices: [
        {'name': 'Portuguese Portugal', 'locale': 'pt-PT', 'quality': 'high'},
      ],
    );

    expect(result, {'name': 'Portuguese Portugal', 'locale': 'pt-PT'});
  });

  test('returns null when no voice matches the requested language', () {
    final result = PokemonTtsVoiceSelector.select(
      locale: AppLocale.pt.tag,
      voices: [
        {'name': 'English', 'locale': 'en-US', 'quality': 500},
      ],
    );

    expect(result, isNull);
  });
}
