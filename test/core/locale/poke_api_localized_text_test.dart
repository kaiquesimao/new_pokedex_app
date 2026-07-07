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
}
