import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/features/pokemon/data/models/evolution_models.dart';
import 'package:pokedex_app/features/pokemon/data/models/filter_models.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';

class PokemonRemoteDataSource {
  PokemonRemoteDataSource(this._client);

  final PokeApiClient _client;

  Future<PokemonListResponse> fetchPokemonList({
    int offset = 0,
    int limit = 20,
  }) {
    return _client.getPokemonList(offset: offset, limit: limit);
  }

  Future<PokemonResponse> fetchPokemon(int id) {
    return _client.getPokemon(id);
  }

  Future<PokemonSpeciesResponse> fetchPokemonSpecies(int id) {
    return _client.getPokemonSpecies(id);
  }

  Future<PokemonFormResponse> fetchPokemonForm(int id) {
    return _client.getPokemonForm(id);
  }

  Future<GenerationResponse> fetchGeneration(int id) {
    return _client.getGeneration(id);
  }

  Future<TypeResponse> fetchType(String name) {
    return _client.getType(name);
  }

  Future<EvolutionChainResponse> fetchEvolutionChain(int id) {
    return _client.getEvolutionChain(id);
  }
}
