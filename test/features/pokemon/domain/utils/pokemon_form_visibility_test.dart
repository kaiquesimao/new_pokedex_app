import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_form_visibility.dart';

void main() {
  group('PokemonResponse catalog metadata', () {
    test('parses is_default and primary form from pokemon payload', () {
      final response = PokemonResponse.fromJson({
        'id': 10033,
        'name': 'venusaur-mega',
        'is_default': false,
        'forms': [
          {
            'name': 'venusaur-mega',
            'url': 'https://pokeapi.co/api/v2/pokemon-form/10133/',
          },
        ],
        'height': 24,
        'weight': 1555,
        'sprites': <String, dynamic>{},
        'types': <dynamic>[],
        'stats': <dynamic>[],
        'abilities': <dynamic>[],
      });

      expect(response.isDefault, isFalse);
      expect(response.primaryFormId, 10133);
    });

    test('parses species id from pokemon.species url', () {
      final response = PokemonResponse.fromJson({
        'id': 10301,
        'name': 'zygarde-mega',
        'is_default': false,
        'species': {
          'name': 'zygarde',
          'url': 'https://pokeapi.co/api/v2/pokemon-species/718/',
        },
        'height': 77,
        'weight': 6100,
        'sprites': <String, dynamic>{},
        'types': <dynamic>[],
        'stats': <dynamic>[],
        'abilities': <dynamic>[],
      });

      expect(response.speciesId, 718);
    });
  });

  group('includesSummaryNamed', () {
    const mega = PokemonSummary(
      id: 10033,
      name: 'venusaur-mega',
      types: [],
      isDefault: false,
      isMega: true,
    );

    const regional = PokemonSummary(
      id: 10091,
      name: 'rattata-alola',
      types: [],
      isDefault: false,
    );

    const base = PokemonSummary(
      id: 3,
      name: 'venusaur',
      types: [],
      isDefault: true,
    );

    test('uses API flags for mega and alternate forms', () {
      expect(
        PokemonFormVisibility.includesSummaryNamed(
          summary: mega,
          showMegaEvolutions: false,
          showOtherForms: true,
        ),
        isFalse,
      );
      expect(
        PokemonFormVisibility.includesSummaryNamed(
          summary: regional,
          showMegaEvolutions: true,
          showOtherForms: false,
        ),
        isFalse,
      );
      expect(
        PokemonFormVisibility.includesSummaryNamed(
          summary: base,
          showMegaEvolutions: false,
          showOtherForms: false,
        ),
        isTrue,
      );
    });
  });

  group('isMegaForm', () {
    test('detects mega suffix variants', () {
      expect(PokemonFormVisibility.isMegaForm('venusaur-mega'), isTrue);
      expect(PokemonFormVisibility.isMegaForm('charizard-mega-x'), isTrue);
    });

    test('does not flag base species', () {
      expect(PokemonFormVisibility.isMegaForm('charizard'), isFalse);
    });
  });

  group('regionalFormKey', () {
    test('extracts regional suffix from alternate forms', () {
      expect(PokemonFormVisibility.regionalFormKey('grimer-alola'), 'alola');
      expect(PokemonFormVisibility.regionalFormKey('muk-alola'), 'alola');
      expect(PokemonFormVisibility.regionalFormKey('meowth-galar'), 'galar');
    });

    test('returns null for base and mega forms', () {
      expect(PokemonFormVisibility.regionalFormKey('grimer'), isNull);
      expect(
        PokemonFormVisibility.regionalFormKey('charizard-mega-x'),
        isNull,
      );
    });

    test('isRegionalForm delegates to regionalFormKey', () {
      expect(PokemonFormVisibility.isRegionalForm('grimer-alola'), isTrue);
      expect(PokemonFormVisibility.isRegionalForm('grimer'), isFalse);
    });
  });
}
