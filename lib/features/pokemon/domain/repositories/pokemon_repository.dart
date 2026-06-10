import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_ref.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';

abstract class PokemonRepository {
  Future<PokemonPage> getPokemonPage({required int offset, int limit = 20});

  Future<PokemonListSlice> getPokemonListSlice({
    required int offset,
    int limit = 20,
  });

  Future<PokemonDetail> getPokemonDetail(int id);

  Future<EvolutionChain> getEvolutionChain(int pokemonId);

  Future<List<PokemonRef>> getAllPokemonRefs();

  Future<void> warmPokemonNameIndex();

  Future<bool> isNameIndexReady();

  Future<List<PokemonRef>> searchPokemonRefsByName(String query);

  Future<List<PokemonRef>> getIndexedPokemonRefs();

  Future<List<int>> getPokemonIdsForGeneration(int generationId);

  Future<List<int>> getPokemonIdsForTypes(List<PokemonType> types);

  Future<Set<PokemonType>> getTypesWeakTo(PokemonType attackType);

  Future<PokemonSummary> getSummaryById(int id);

  Future<List<PokemonSummary>> getSummariesByIds(
    List<int> ids, {
    PokemonListFilters? filters,
    Set<PokemonType>? weakToTypes,
  });
}
