import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_list_filter_utils.dart';

void main() {
  const bulbasaur = PokemonSummary(
    id: 1,
    slug: 'bulbasaur',
    name: 'bulbasaur',
    types: [PokemonType.grass, PokemonType.poison],
    height: 7,
    weight: 69,
  );

  const charmander = PokemonSummary(
    id: 4,
    slug: 'charmander',
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

  test('empty formCategories keeps defaults only', () {
    final result = PokemonListFilterUtils.apply(
      items: const [
        PokemonSummary(
          id: 1,
          slug: 'bulbasaur',
          name: 'bulbasaur',
          types: [],
          isDefault: true,
        ),
        PokemonSummary(
          id: 10033,
          slug: 'venusaur-mega',
          name: 'venusaur-mega',
          types: [],
          isDefault: false,
          isMega: true,
        ),
      ],
      filters: const PokemonListFilters(),
    );
    expect(result.map((e) => e.id), [1]);
  });

  test('mega formCategories excludes defaults', () {
    final result = PokemonListFilterUtils.apply(
      items: const [
        PokemonSummary(
          id: 3,
          slug: 'venusaur',
          name: 'venusaur',
          types: [],
          isDefault: true,
        ),
        PokemonSummary(
          id: 10033,
          slug: 'venusaur-mega',
          name: 'venusaur-mega',
          types: [],
          isDefault: false,
          isMega: true,
        ),
      ],
      filters: const PokemonListFilters(
        formCategories: {PokemonFormCategory.mega},
      ),
    );
    expect(result.map((e) => e.id), [10033]);
  });

  test('gigantamax and regional use slug when display name differs', () {
    const items = [
      PokemonSummary(
        id: 6,
        slug: 'charizard',
        name: 'Charizard',
        types: [],
        isDefault: true,
      ),
      PokemonSummary(
        id: 10195,
        slug: 'charizard-gmax',
        name: 'Charizard Gigantamax',
        types: [],
        isDefault: false,
      ),
      PokemonSummary(
        id: 10091,
        slug: 'rattata-alola',
        name: 'Rattata Alola',
        types: [],
        isDefault: false,
      ),
      PokemonSummary(
        id: 10117,
        slug: 'greninja-battle-bond',
        name: 'Greninja Battle Bond',
        types: [],
        isDefault: false,
      ),
    ];

    expect(
      PokemonListFilterUtils.apply(
        items: items,
        filters: const PokemonListFilters(
          formCategories: {PokemonFormCategory.gigantamax},
        ),
      ).map((e) => e.id),
      [10195],
    );
    expect(
      PokemonListFilterUtils.apply(
        items: items,
        filters: const PokemonListFilters(
          formCategories: {PokemonFormCategory.regional},
        ),
      ).map((e) => e.id),
      [10091],
    );
    expect(
      PokemonListFilterUtils.apply(
        items: items,
        filters: const PokemonListFilters(
          formCategories: {PokemonFormCategory.otherSpecial},
        ),
      ).map((e) => e.id),
      [10117],
    );
  });
}
