import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';

void main() {
  group('PokemonListFilters modes', () {
    test('usesSearchOnlyMode when only search is active', () {
      const filters = PokemonListFilters(searchQuery: 'pika');

      expect(filters.usesSearchOnlyMode, isTrue);
      expect(filters.usesCatalogMode, isTrue);
      expect(filters.hasStructuralFilters, isFalse);
    });

    test(
      'usesCatalogMode without search-only when structural filters exist',
      () {
        const filters = PokemonListFilters(
          searchQuery: 'pika',
          typeFilter: PokemonType.fire,
        );

        expect(filters.usesSearchOnlyMode, isFalse);
        expect(filters.usesCatalogMode, isTrue);
        expect(filters.hasStructuralFilters, isTrue);
      },
    );

    test('single type filter mode holds at most one type', () {
      const filters = PokemonListFilters(typeFilter: PokemonType.grass);

      expect(filters.typeFilter, PokemonType.grass);
      expect(filters.hasStructuralFilters, isTrue);
      expect(filters.activeFilterCount, 1);
    });

    test('paginated mode when no filters are active', () {
      const filters = PokemonListFilters();

      expect(filters.usesSearchOnlyMode, isFalse);
      expect(filters.usesCatalogMode, isFalse);
      expect(filters.hasStructuralFilters, isFalse);
    });

    test('catalog mode for sort-only changes', () {
      const filters = PokemonListFilters(sort: PokemonSortOption.nameAsc);

      expect(filters.usesSearchOnlyMode, isFalse);
      expect(filters.usesCatalogMode, isTrue);
      expect(filters.hasStructuralFilters, isFalse);
    });
  });
}
