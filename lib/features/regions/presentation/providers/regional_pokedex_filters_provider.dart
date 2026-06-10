import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';

final regionalPokedexFiltersProvider =
    StateProvider.family<PokemonListFilters, String>(
  (ref, regionName) => const PokemonListFilters(),
);
