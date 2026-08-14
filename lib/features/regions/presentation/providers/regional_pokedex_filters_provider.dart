import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:riverpod/misc.dart';

class RegionalPokedexFiltersNotifier(final String regionName)
    extends Notifier<PokemonListFilters> {
  @override
  PokemonListFilters build() => const PokemonListFilters();

  void update(
    PokemonListFilters Function(PokemonListFilters current) transform,
  ) {
    state = transform(state);
  }
}

final NotifierProviderFamily<
  RegionalPokedexFiltersNotifier,
  PokemonListFilters,
  String
>
regionalPokedexFiltersProvider =
    NotifierProvider.family<
      RegionalPokedexFiltersNotifier,
      PokemonListFilters,
      String
    >(RegionalPokedexFiltersNotifier.new);
