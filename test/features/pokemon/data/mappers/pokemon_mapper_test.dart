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

    final summary = PokemonMapper.toSummary(response);

    expect(summary.id, 1);
    expect(summary.name, 'bulbasaur');
    expect(summary.types, [PokemonType.grass, PokemonType.poison]);
    expect(summary.spriteUrl, isNotNull);
  });
}
