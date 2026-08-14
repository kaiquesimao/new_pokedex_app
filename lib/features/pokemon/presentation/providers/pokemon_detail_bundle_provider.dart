import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:riverpod/misc.dart';

class const PokemonDetailBundle({
  required final PokemonDetail detail,
  required final EvolutionChain evolution,
  final List<dynamic> flavorTextEntries = const [],
  final bool isOfflineMode = false,
});

final FutureProviderFamily<PokemonDetailBundle, int>
pokemonDetailBundleProvider = FutureProvider.family<PokemonDetailBundle, int>((
  ref,
  pokemonId,
) async {
  final repo = ref.watch(pokemonRepositoryProvider);
  final detail = await repo.getPokemonDetail(pokemonId);
  final offlineFromDetail = repo.takeOfflineFallbackUsed();
  final evolution = await repo.getEvolutionChain(pokemonId);
  final offlineFromEvolution = repo.takeOfflineFallbackUsed();

  return PokemonDetailBundle(
    detail: detail,
    evolution: evolution,
    flavorTextEntries: detail.flavorTextEntries,
    isOfflineMode: offlineFromDetail || offlineFromEvolution,
  );
});
