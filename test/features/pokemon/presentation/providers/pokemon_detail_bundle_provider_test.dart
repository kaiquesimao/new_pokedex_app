import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/presentation/pages/pokemon_detail_page.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_detail_bundle_provider.dart';

void main() {
  test(
    'shouldReloadPokemonDetailOnConnectivityRestore handles offline states',
    () {
      const offlineError = AsyncError<PokemonDetailBundle>(
        OfflineEmptyCacheException(),
        StackTrace.empty,
      );
      expect(
        shouldReloadPokemonDetailOnConnectivityRestore(offlineError),
        isTrue,
      );

      const offlineData = AsyncData(
        PokemonDetailBundle(
          detail: _sampleDetail,
          evolution: EvolutionChain(
            root: EvolutionChainNode(
              speciesId: 25,
              pokemonId: 25,
              speciesName: 'pikachu',
            ),
            currentPokemonId: 25,
            currentSpeciesId: 25,
          ),
          isOfflineMode: true,
        ),
      );
      expect(
        shouldReloadPokemonDetailOnConnectivityRestore(offlineData),
        isTrue,
      );

      const onlineData = AsyncData(
        PokemonDetailBundle(
          detail: _sampleDetail,
          evolution: EvolutionChain(
            root: EvolutionChainNode(
              speciesId: 25,
              pokemonId: 25,
              speciesName: 'pikachu',
            ),
            currentPokemonId: 25,
            currentSpeciesId: 25,
          ),
        ),
      );
      expect(
        shouldReloadPokemonDetailOnConnectivityRestore(onlineData),
        isFalse,
      );
    },
  );
}

const _sampleDetail = PokemonDetail(
  id: 25,
  name: 'pikachu',
  height: 4,
  weight: 60,
  types: [PokemonType.electric],
  stats: [],
  abilities: [],
);
