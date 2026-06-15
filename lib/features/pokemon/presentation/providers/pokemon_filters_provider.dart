import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';

class PokemonFiltersNotifier extends Notifier<PokemonListFilters> {
  @override
  PokemonListFilters build() => const PokemonListFilters();

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setTypeFilter(PokemonType? type) {
    state = state.copyWith(typeFilter: type, clearTypeFilter: type == null);
  }

  void setWeakness(PokemonType? type) {
    state = state.copyWith(weakness: type, clearWeakness: type == null);
  }

  void setHeightBucket(PokemonHeightBucket? bucket) {
    state = state.copyWith(
      heightBucket: bucket,
      clearHeightBucket: bucket == null,
    );
  }

  void setWeightBucket(PokemonWeightBucket? bucket) {
    state = state.copyWith(
      weightBucket: bucket,
      clearWeightBucket: bucket == null,
    );
  }

  void setGeneration(int? generationId) {
    state = state.copyWith(
      generationId: generationId,
      clearGeneration: generationId == null,
    );
  }

  void setSort(PokemonSortOption sort) {
    state = state.copyWith(sort: sort);
  }

  void clearAll() {
    state = const PokemonListFilters();
  }
}

final pokemonFiltersProvider =
    NotifierProvider<PokemonFiltersNotifier, PokemonListFilters>(
      PokemonFiltersNotifier.new,
    );
