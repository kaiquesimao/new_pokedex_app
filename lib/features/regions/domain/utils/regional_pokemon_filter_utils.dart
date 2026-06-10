import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/regions/domain/entities/regional_pokemon.dart';

class RegionalPokemonFilterUtils {
  static List<RegionalPokemon> apply({
    required List<RegionalPokemon> items,
    required PokemonListFilters filters,
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

      return true;
    }).toList();

    return sort(filtered, filters.sort);
  }

  static List<RegionalPokemon> sort(
    List<RegionalPokemon> items,
    PokemonSortOption sort,
  ) {
    final sorted = List<RegionalPokemon>.from(items);
    switch (sort) {
      case PokemonSortOption.numberAsc:
        sorted.sort((a, b) => a.regionalNumber.compareTo(b.regionalNumber));
      case PokemonSortOption.numberDesc:
        sorted.sort((a, b) => b.regionalNumber.compareTo(a.regionalNumber));
      case PokemonSortOption.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case PokemonSortOption.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
    }
    return sorted;
  }
}
