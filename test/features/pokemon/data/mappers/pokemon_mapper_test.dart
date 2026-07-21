import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/data/mappers/pokemon_mapper.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';

void main() {
  test('toSummary maps bulbasaur fixture correctly', () async {
    final jsonString = await File(
      'test/fixtures/bulbasaur.json',
    ).readAsString();
    final response = PokemonResponse.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );

    final summary = PokemonMapper.toSummary(response, pokeApiCode: 'en');

    expect(summary.id, 1);
    expect(summary.name, 'Bulbasaur');
    expect(summary.types, [PokemonType.grass, PokemonType.poison]);
    expect(summary.spriteUrl, response.spriteUrl);
    expect(summary.spriteUrl, contains('other/home'));
  });

  test('toSummary appends form label for non-default varieties', () {
    final species = PokemonSpeciesResponse.withFlavorText(
      id: 6,
      flavorText: '',
      names: [
        {
          'name': 'Charizard',
          'language': {'name': 'en'},
        },
      ],
    );
    const response = PokemonResponse(
      id: 10034,
      name: 'charizard-mega-x',
      height: 17,
      weight: 1105,
      types: [],
      stats: [],
      abilities: [],
      spriteUrl: null,
      listSpriteUrl: null,
      isDefault: false,
      isMega: true,
      speciesId: 6,
    );

    final summary = PokemonMapper.toSummary(
      response,
      pokeApiCode: 'en',
      species: species,
    );

    expect(summary.slug, 'charizard-mega-x');
    expect(summary.name, 'Charizard Mega X');
  });
}
