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

    test('formCategories are structural; showShiny is not', () {
      const withForms = PokemonListFilters(
        formCategories: {PokemonFormCategory.mega},
      );
      expect(withForms.hasStructuralFilters, isTrue);
      expect(withForms.usesCatalogMode, isTrue);
      expect(withForms.activeFilterCount, 1);

      const shinyOnly = PokemonListFilters(showShiny: true);
      expect(shinyOnly.hasStructuralFilters, isFalse);
      expect(shinyOnly.usesCatalogMode, isFalse);
      expect(shinyOnly.hasActiveFilters, isTrue);
      expect(shinyOnly.activeFilterCount, 1);
    });

    test('cleared resets forms and shiny', () {
      const filters = PokemonListFilters(
        formCategories: {PokemonFormCategory.gigantamax},
        showShiny: true,
      );
      final cleared = filters.cleared();
      expect(cleared.formCategories, isEmpty);
      expect(cleared.showShiny, isFalse);
    });
  });
}
