import 'package:dio/dio.dart';
import 'package:pokedex_app/core/network/network_errors.dart';
import 'package:pokedex_app/features/pokemon/data/models/evolution_models.dart';
import 'package:pokedex_app/features/pokemon/data/models/filter_models.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/regions/data/models/region_models.dart';

class PokeApiClient {
  PokeApiClient(this._dio);

  final Dio _dio;

  Future<PokemonListResponse> getPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/pokemon',
        queryParameters: {'offset': offset, 'limit': limit},
      );
      return PokemonListResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, fallback: 'Failed to load pokemon list');
    }
  }

  Future<PokemonResponse> getPokemon(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/pokemon/$id');
      return PokemonResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, fallback: 'Failed to load pokemon');
    }
  }

  Future<RegionListResponse> getRegions() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/region');
      return RegionListResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, fallback: 'Failed to load regions');
    }
  }

  Future<RegionDetailResponse> getRegion(String name) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/region/$name');
      return RegionDetailResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, fallback: 'Failed to load region');
    }
  }

  Future<PokedexResponse> getPokedex(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/pokedex/$id');
      return PokedexResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, fallback: 'Failed to load pokedex');
    }
  }

  Future<GenerationResponse> getGeneration(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/generation/$id');
      return GenerationResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, fallback: 'Failed to load generation');
    }
  }

  Future<TypeResponse> getType(String name) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/type/$name');
      return TypeResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, fallback: 'Failed to load type');
    }
  }

  Future<EvolutionChainResponse> getEvolutionChain(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/evolution-chain/$id',
      );
      return EvolutionChainResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, fallback: 'Failed to load evolution chain');
    }
  }

  Future<PokemonSpeciesResponse> getPokemonSpecies(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/pokemon-species/$id',
      );
      return PokemonSpeciesResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, fallback: 'Failed to load pokemon species');
    }
  }
}
