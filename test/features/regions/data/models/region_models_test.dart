import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/regions/data/models/region_models.dart';

void main() {
  test('PokedexResponse maps pokemon entries', () async {
    final jsonString = await File(
      'test/fixtures/kanto_pokedex.json',
    ).readAsString();
    final response = PokedexResponse.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );

    expect(response.id, 2);
    expect(response.pokemonEntries, isNotEmpty);
    expect(response.pokemonEntries.first.entryNumber, 1);
    expect(response.pokemonEntries.first.pokemonSpecies.name, 'bulbasaur');
    expect(response.pokemonEntries.first.pokemonSpecies.id, 1);
  });
}
