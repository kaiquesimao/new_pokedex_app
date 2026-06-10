import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';

class PokemonListFilterUtils {
  static List<PokemonSummary> apply({
    required List<PokemonSummary> items,
    required PokemonListFilters filters,
    Set<PokemonType>? weakToTypes,
  }) {
    final query = filters.searchQuery.trim().toLowerCase();
    final filtered = items.where((pokemon) {
      if (query.isNotEmpty && !pokemon.name.toLowerCase().contains(query)) {
        return false;
      }

      if (filters.typeFilter != null &&
          !pokemon.types.contains(filters.typeFilter)) {
        return false;
      }

      if (filters.weakness != null) {
        final weakTypes = weakToTypes ?? const <PokemonType>{};
        if (!pokemon.types.any(weakTypes.contains)) {
          return false;
        }
      }

      if (filters.heightBucket != null) {
        final height = pokemon.height;
        if (height == null || !filters.heightBucket!.matches(height)) {
          return false;
        }
      }

      if (filters.weightBucket != null) {
        final weight = pokemon.weight;
        if (weight == null || !filters.weightBucket!.matches(weight)) {
          return false;
        }
      }

      return true;
    }).toList();

    return sort(filtered, filters.sort);
  }

  static List<PokemonSummary> sort(
    List<PokemonSummary> items,
    PokemonSortOption sort,
  ) {
    final sorted = List<PokemonSummary>.from(items);
    switch (sort) {
      case PokemonSortOption.numberAsc:
        sorted.sort((a, b) => a.id.compareTo(b.id));
      case PokemonSortOption.numberDesc:
        sorted.sort((a, b) => b.id.compareTo(a.id));
      case PokemonSortOption.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case PokemonSortOption.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
    }
    return sorted;
  }
}
