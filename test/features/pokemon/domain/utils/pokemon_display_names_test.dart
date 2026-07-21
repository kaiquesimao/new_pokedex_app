import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_display_names.dart';

void main() {
  group('PokemonDisplayNames.resolve', () {
    test('keeps species name for default forms', () {
      expect(
        PokemonDisplayNames.resolve(
          apiName: 'charizard',
          speciesLocalizedName: 'Charizard',
          isDefault: true,
        ),
        'Charizard',
      );
    });

    test('appends Mega X from API slug for mega forms', () {
      expect(
        PokemonDisplayNames.resolve(
          apiName: 'charizard-mega-x',
          speciesLocalizedName: 'Charizard',
          isDefault: false,
        ),
        'Charizard Mega X',
      );
    });

    test('appends Mega Y from API slug', () {
      expect(
        PokemonDisplayNames.resolve(
          apiName: 'charizard-mega-y',
          speciesLocalizedName: 'Charizard',
          isDefault: false,
        ),
        'Charizard Mega Y',
      );
    });

    test('appends Gigantamax from gmax slug', () {
      expect(
        PokemonDisplayNames.resolve(
          apiName: 'charizard-gmax',
          speciesLocalizedName: 'Charizard',
          isDefault: false,
        ),
        'Charizard Gigantamax',
      );
    });

    test('appends regional form from slug', () {
      expect(
        PokemonDisplayNames.resolve(
          apiName: 'grimer-alola',
          speciesLocalizedName: 'Grimer',
          isDefault: false,
        ),
        'Grimer Alola',
      );
    });

    test('title-cases slug when species name is missing', () {
      expect(
        PokemonDisplayNames.resolve(
          apiName: 'charizard-mega-x',
          isDefault: false,
        ),
        'Charizard Mega X',
      );
    });

    test('infers non-default from slug when isDefault is null', () {
      expect(
        PokemonDisplayNames.resolve(
          apiName: 'charizard-mega-x',
          speciesLocalizedName: 'Charizard',
        ),
        'Charizard Mega X',
      );
    });

    test('does not treat hyphenated default species as forms', () {
      expect(
        PokemonDisplayNames.resolve(
          apiName: 'mr-mime',
          speciesLocalizedName: 'Mr. Mime',
          isDefault: true,
        ),
        'Mr. Mime',
      );
      expect(
        PokemonDisplayNames.resolve(
          apiName: 'mr-mime',
          speciesLocalizedName: 'Mr. Mime',
        ),
        'Mr. Mime',
      );
    });
  });
}
