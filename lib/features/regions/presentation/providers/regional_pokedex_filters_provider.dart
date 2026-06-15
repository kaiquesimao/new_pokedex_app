import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';

class RegionalPokedexFiltersNotifier extends Notifier<PokemonListFilters> {
  RegionalPokedexFiltersNotifier(this.regionName);

  final String regionName;

  @override
  PokemonListFilters build() => const PokemonListFilters();

  void update(
    PokemonListFilters Function(PokemonListFilters current) transform,
  ) {
    state = transform(state);
  }
}

final regionalPokedexFiltersProvider =
    NotifierProvider.family<
      RegionalPokedexFiltersNotifier,
      PokemonListFilters,
      String
    >(RegionalPokedexFiltersNotifier.new);
