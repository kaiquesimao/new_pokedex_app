import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/pokemon/data/mappers/pokemon_mapper.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';

void main() {
  test('toSummary maps shinyDisplayUrl', () {
    final response = PokemonResponse.fromJson({
      'id': 25,
      'name': 'pikachu',
      'height': 4,
      'weight': 60,
      'sprites': {
        'front_default': 'https://example.com/25.png',
        'front_shiny': 'https://example.com/shiny/25.png',
        'other': {
          'home': {
            'front_default': 'https://example.com/home/25.png',
            'front_shiny': 'https://example.com/home/shiny/25.png',
          },
        },
      },
      'types': [
        {
          'slot': 1,
          'type': {
            'name': 'electric',
            'url': 'https://pokeapi.co/api/v2/type/13/',
          },
        },
      ],
      'stats': <dynamic>[],
      'abilities': <dynamic>[],
    });
    final summary = PokemonMapper.toSummary(
      response,
      pokeApiCode: 'en',
    );
    expect(
      summary.shinySpriteUrl,
      'https://example.com/home/shiny/25.png',
    );
  });
}
