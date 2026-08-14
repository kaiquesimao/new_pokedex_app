import 'package:pokedex_app/core/constants/pokemon_types.dart';

enum PokemonFormCategory {
  mega,
  gigantamax,
  regional,
  otherSpecial,
}

enum PokemonSortOption { numberAsc, numberDesc, nameAsc, nameDesc }

enum PokemonHeightBucket {
  small,
  medium,
  large;

  bool matches(int heightDm) => switch (this) {
    small => heightDm < 10,
    medium => heightDm >= 10 && heightDm <= 20,
    large => heightDm > 20,
  };
}

enum PokemonWeightBucket {
  light,
  medium,
  heavy;

  bool matches(int weightHg) => switch (this) {
    light => weightHg < 100,
    medium => weightHg >= 100 && weightHg <= 1000,
    heavy => weightHg > 1000,
  };
}

class const PokemonListFilters({
  final String searchQuery = '',
  final PokemonType? typeFilter,
  final PokemonType? weakness,
  final PokemonHeightBucket? heightBucket,
  final PokemonWeightBucket? weightBucket,
  final int? generationId,
  final Set<PokemonFormCategory> formCategories = const {},
  final bool showShiny = false,
  final PokemonSortOption sort = PokemonSortOption.numberAsc,
}) {
  bool get hasSearch => searchQuery.trim().isNotEmpty;

  bool get hasStructuralFilters =>
      typeFilter != null ||
      weakness != null ||
      heightBucket != null ||
      weightBucket != null ||
      generationId != null ||
      formCategories.isNotEmpty;

  bool get usesSearchOnlyMode => hasSearch && !hasStructuralFilters;

  bool get hasActiveFilters =>
      hasSearch ||
      hasStructuralFilters ||
      showShiny ||
      sort != PokemonSortOption.numberAsc;

  bool get usesCatalogMode =>
      hasStructuralFilters || hasSearch || sort != PokemonSortOption.numberAsc;

  int get activeFilterCount {
    var count = 0;
    if (typeFilter != null) count++;
    if (weakness != null) count++;
    if (heightBucket != null) count++;
    if (weightBucket != null) count++;
    if (generationId != null) count++;
    count += formCategories.length;
    if (showShiny) count++;
    if (sort != PokemonSortOption.numberAsc) count++;
    return count;
  }

  PokemonListFilters copyWith({
    String? searchQuery,
    PokemonType? typeFilter,
    bool clearTypeFilter = false,
    PokemonType? weakness,
    bool clearWeakness = false,
    PokemonHeightBucket? heightBucket,
    bool clearHeightBucket = false,
    PokemonWeightBucket? weightBucket,
    bool clearWeightBucket = false,
    int? generationId,
    bool clearGeneration = false,
    Set<PokemonFormCategory>? formCategories,
    bool clearFormCategories = false,
    bool? showShiny,
    PokemonSortOption? sort,
  }) {
    return PokemonListFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      weakness: clearWeakness ? null : (weakness ?? this.weakness),
      heightBucket: clearHeightBucket
          ? null
          : (heightBucket ?? this.heightBucket),
      weightBucket: clearWeightBucket
          ? null
          : (weightBucket ?? this.weightBucket),
      generationId: clearGeneration
          ? null
          : (generationId ?? this.generationId),
      formCategories: clearFormCategories
          ? const {}
          : (formCategories ?? this.formCategories),
      showShiny: showShiny ?? this.showShiny,
      sort: sort ?? this.sort,
    );
  }

  PokemonListFilters cleared() => const PokemonListFilters();
}

const kPokemonGenerationIds = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];
