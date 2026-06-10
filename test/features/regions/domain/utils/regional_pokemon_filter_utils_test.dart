import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/regions/domain/entities/regional_pokemon.dart';
import 'package:pokedex_app/features/regions/domain/utils/regional_pokemon_filter_utils.dart';

void main() {
  final items = [
    const RegionalPokemon(
      regionalNumber: 2,
      pokemonId: 4,
      name: 'charmander',
      types: [PokemonType.fire],
    ),
    const RegionalPokemon(
      regionalNumber: 1,
      pokemonId: 1,
      name: 'bulbasaur',
      types: [PokemonType.grass, PokemonType.poison],
    ),
  ];

  test('filters by type', () {
    final result = RegionalPokemonFilterUtils.apply(
      items: items,
      filters: const PokemonListFilters(typeFilter: PokemonType.fire),
    );

    expect(result, hasLength(1));
    expect(result.first.name, 'charmander');
  });

  test('sorts by regional number ascending', () {
    final result = RegionalPokemonFilterUtils.apply(
      items: items,
      filters: const PokemonListFilters(sort: PokemonSortOption.numberAsc),
    );

    expect(result.map((e) => e.regionalNumber), [1, 2]);
  });
}
