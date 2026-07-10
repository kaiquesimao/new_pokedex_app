import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/poke_api_localized_text.dart';

void main() {
  group('PokeApiLocalizedText.pickName', () {
    test('prefers pt-br then en when only en and fr exist', () {
      final entries = [
        {
          'name': 'Pikachu',
          'language': {'name': 'en'},
        },
        {
          'name': 'Pikachu',
          'language': {'name': 'fr'},
        },
      ];

      expect(
        PokeApiLocalizedText.pickName(entries, 'pt-br'),
        'Pikachu',
      );
    });

    test('uses en when pt-br is missing', () {
      final entries = [
        {
          'name': 'Bulbasaur',
          'language': {'name': 'en'},
        },
        {
          'name': 'Bulbizarre',
          'language': {'name': 'fr'},
        },
      ];

      expect(
        PokeApiLocalizedText.pickName(entries, 'pt-br'),
        'Bulbasaur',
      );
    });
  });

  group('PokeApiLocalizedText.pickFlavorText', () {
    test('normalizes newlines and form feeds to spaces', () {
      final entries = [
        {
          'flavor_text': 'Line one\nLine two\fLine three',
          'language': {'name': 'en'},
        },
      ];

      expect(
        PokeApiLocalizedText.pickFlavorText(entries, 'en'),
        'Line one Line two Line three',
      );
    });
  });

  group('PokeApiLocalizedText.hasEntry', () {
    test('returns true when lang and text exist', () {
      final entries = [
        {
          'name': 'Monstro',
          'language': {'name': 'pt-br'},
        },
      ];
      expect(PokeApiLocalizedText.hasEntry(entries, 'pt-br', 'name'), isTrue);
    });

    test('returns false when only en exists', () {
      final entries = [
        {
          'name': 'Monster',
          'language': {'name': 'en'},
        },
      ];
      expect(PokeApiLocalizedText.hasEntry(entries, 'pt-br', 'name'), isFalse);
    });
  });

  group('PokeApiLocalizedText.pickOfficial', () {
    test('returns null when target lang missing', () {
      final entries = [
        {
          'genus': 'Mouse Pokémon',
          'language': {'name': 'en'},
        },
      ];
      expect(
        PokeApiLocalizedText.pickOfficial(entries, 'pt-br', 'genus'),
        isNull,
      );
    });

    test('returns text without falling back to en', () {
      final entries = [
        {
          'genus': 'Mouse Pokémon',
          'language': {'name': 'en'},
        },
        {
          'genus': 'Pokémon Rato',
          'language': {'name': 'pt-br'},
        },
      ];
      expect(
        PokeApiLocalizedText.pickOfficial(entries, 'pt-br', 'genus'),
        'Pokémon Rato',
      );
    });
  });

  group('PokeApiLocalizedText.pickEnglish', () {
    test('returns en flavor text', () {
      final entries = [
        {
          'flavor_text': 'A mouse.',
          'language': {'name': 'en'},
        },
      ];
      expect(
        PokeApiLocalizedText.pickEnglish(entries, 'flavor_text'),
        'A mouse.',
      );
    });
  });
}
