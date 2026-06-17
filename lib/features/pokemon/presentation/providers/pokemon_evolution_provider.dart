import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:riverpod/misc.dart';

final FutureProviderFamily<EvolutionChain, int> pokemonEvolutionProvider =
    FutureProvider.family<EvolutionChain, int>((
      ref,
      pokemonId,
    ) async {
      final repo = ref.watch(pokemonRepositoryProvider);
      return repo.getEvolutionChain(pokemonId);
    });
