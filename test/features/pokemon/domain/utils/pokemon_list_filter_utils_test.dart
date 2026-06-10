import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_list_filter_utils.dart';

void main() {
  final bulbasaur = PokemonSummary(
    id: 1,
    name: 'bulbasaur',
    types: [PokemonType.grass, PokemonType.poison],
    height: 7,
    weight: 69,
  );

  final charmander = PokemonSummary(
    id: 4,
    name: 'charmander',
    types: [PokemonType.fire],
    height: 6,
    weight: 85,
  );

  final items = [bulbasaur, charmander];

  test('filters by search query', () {
    final result = PokemonListFilterUtils.apply(
      items: items,
      filters: const PokemonListFilters(searchQuery: 'char'),
    );

    expect(result.map((p) => p.id), [4]);
  });

  test('filters by selected type', () {
    final result = PokemonListFilterUtils.apply(
      items: items,
      filters: const PokemonListFilters(typeFilter: PokemonType.fire),
    );

    expect(result.map((p) => p.id), [4]);
  });

  test('filters by weakness types', () {
    final result = PokemonListFilterUtils.apply(
      items: items,
      filters: const PokemonListFilters(weakness: PokemonType.fire),
      weakToTypes: {PokemonType.grass},
    );

    expect(result.map((p) => p.id), [1]);
  });

  test('filters by height bucket', () {
    final result = PokemonListFilterUtils.apply(
      items: items,
      filters: const PokemonListFilters(
        heightBucket: PokemonHeightBucket.small,
      ),
    );

    expect(result.map((p) => p.id), [1, 4]);
  });

  test('sorts by name descending', () {
    final result = PokemonListFilterUtils.sort(
      items,
      PokemonSortOption.nameDesc,
    );

    expect(result.map((p) => p.name), ['charmander', 'bulbasaur']);
  });
}
