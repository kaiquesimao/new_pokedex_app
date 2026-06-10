import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/core/network/dio_client.dart';
import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/repositories/pokemon_repository_impl.dart';
import 'package:pokedex_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex_app/features/regions/data/repositories/region_repository_impl.dart';
import 'package:pokedex_app/features/regions/domain/repositories/region_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main.dart');
});

final dioProvider = Provider<Dio>((ref) => createDio());

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final pokeApiClientProvider = Provider<PokeApiClient>(
  (ref) => PokeApiClient(ref.watch(dioProvider)),
);

final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  final remote = PokemonRemoteDataSource(ref.watch(pokeApiClientProvider));
  final local = PokemonLocalDataSource(ref.watch(appDatabaseProvider));
  return PokemonRepositoryImpl(remote: remote, local: local);
});

final regionRepositoryProvider = Provider<RegionRepository>((ref) {
  return RegionRepositoryImpl(client: ref.watch(pokeApiClientProvider));
});
