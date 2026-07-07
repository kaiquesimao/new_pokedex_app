import 'package:dio/dio.dart';
import 'package:pokedex_app/core/locale/api_load_target.dart';
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
      mapDioException(e, loadTarget: ApiLoadTarget.pokemonList);
    }
  }

  Future<PokemonResponse> getPokemon(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/pokemon/$id');
      return PokemonResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.pokemon);
    }
  }

  Future<RegionListResponse> getRegions() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/region');
      return RegionListResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.regions);
    }
  }

  Future<RegionDetailResponse> getRegion(String name) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/region/$name');
      return RegionDetailResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.region);
    }
  }

  Future<PokedexResponse> getPokedex(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/pokedex/$id');
      return PokedexResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.pokedex);
    }
  }

  Future<GenerationResponse> getGeneration(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/generation/$id');
      return GenerationResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.generation);
    }
  }

  Future<TypeResponse> getType(String name) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/type/$name');
      return TypeResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.type);
    }
  }

  Future<Map<String, dynamic>> getAbility(String name) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/ability/$name');
      return response.data ?? {};
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.ability);
    }
  }

  Future<Map<String, dynamic>> fetchEggGroup(String name) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/egg-group/$name',
      );
      return response.data!;
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.eggGroup);
    }
  }

  Future<Map<String, dynamic>> fetchItem(String name) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/item/$name');
      return response.data!;
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.item);
    }
  }

  Future<EvolutionChainResponse> getEvolutionChain(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/evolution-chain/$id',
      );
      return EvolutionChainResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.evolutionChain);
    }
  }

  Future<PokemonSpeciesResponse> getPokemonSpecies(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/pokemon-species/$id',
      );
      return PokemonSpeciesResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.species);
    }
  }

  Future<PokemonFormResponse> getPokemonForm(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/pokemon-form/$id',
      );
      return PokemonFormResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      mapDioException(e, loadTarget: ApiLoadTarget.form);
    }
  }
}
