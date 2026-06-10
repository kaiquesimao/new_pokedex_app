import 'package:pokedex_app/core/constants/pokemon_types.dart';

enum PokemonSortOption {
  numberAsc,
  numberDesc,
  nameAsc,
  nameDesc;

  String get label => switch (this) {
    numberAsc => 'Menor número',
    numberDesc => 'Maior número',
    nameAsc => 'A-Z',
    nameDesc => 'Z-A',
  };
}

enum PokemonHeightBucket {
  small,
  medium,
  large;

  String get label => switch (this) {
    small => 'Baixo (< 1 m)',
    medium => 'Médio (1–2 m)',
    large => 'Alto (> 2 m)',
  };

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

  String get label => switch (this) {
    light => 'Leve (< 10 kg)',
    medium => 'Médio (10–100 kg)',
    heavy => 'Pesado (> 100 kg)',
  };

  bool matches(int weightHg) => switch (this) {
    light => weightHg < 100,
    medium => weightHg >= 100 && weightHg <= 1000,
    heavy => weightHg > 1000,
  };
}

class PokemonListFilters {
  const PokemonListFilters({
    this.searchQuery = '',
    this.typeFilter,
    this.weakness,
    this.heightBucket,
    this.weightBucket,
    this.generationId,
    this.sort = PokemonSortOption.numberAsc,
  });

  final String searchQuery;
  final PokemonType? typeFilter;
  final PokemonType? weakness;
  final PokemonHeightBucket? heightBucket;
  final PokemonWeightBucket? weightBucket;
  final int? generationId;
  final PokemonSortOption sort;

  bool get hasSearch => searchQuery.trim().isNotEmpty;

  bool get hasStructuralFilters =>
      typeFilter != null ||
      weakness != null ||
      heightBucket != null ||
      weightBucket != null ||
      generationId != null;

  bool get usesSearchOnlyMode => hasSearch && !hasStructuralFilters;

  bool get hasActiveFilters =>
      hasSearch || hasStructuralFilters || sort != PokemonSortOption.numberAsc;

  bool get usesCatalogMode =>
      hasStructuralFilters || hasSearch || sort != PokemonSortOption.numberAsc;

  int get activeFilterCount {
    var count = 0;
    if (typeFilter != null) count++;
    if (weakness != null) count++;
    if (heightBucket != null) count++;
    if (weightBucket != null) count++;
    if (generationId != null) count++;
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
      sort: sort ?? this.sort,
    );
  }

  PokemonListFilters cleared() => const PokemonListFilters();
}

const kPokemonGenerations = <({int id, String label})>[
  (id: 1, label: 'Geração I'),
  (id: 2, label: 'Geração II'),
  (id: 3, label: 'Geração III'),
  (id: 4, label: 'Geração IV'),
  (id: 5, label: 'Geração V'),
  (id: 6, label: 'Geração VI'),
  (id: 7, label: 'Geração VII'),
  (id: 8, label: 'Geração VIII'),
  (id: 9, label: 'Geração IX'),
];
