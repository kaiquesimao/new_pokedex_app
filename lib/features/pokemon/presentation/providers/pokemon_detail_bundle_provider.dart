import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';

class PokemonDetailBundle {
  const PokemonDetailBundle({
    required this.detail,
    required this.evolution,
  });

  final PokemonDetail detail;
  final EvolutionChain evolution;
}

final pokemonDetailBundleProvider =
    FutureProvider.family<PokemonDetailBundle, int>((ref, pokemonId) async {
  final repo = ref.watch(pokemonRepositoryProvider);
  final results = await Future.wait([
    repo.getPokemonDetail(pokemonId),
    repo.getEvolutionChain(pokemonId),
  ]);

  return PokemonDetailBundle(
    detail: results[0] as PokemonDetail,
    evolution: results[1] as EvolutionChain,
  );
});
