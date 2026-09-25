import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/core/env/env.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/core/locale/game_text_resolver_provider.dart';
import 'package:pokedex_app/core/network/dio_client.dart';
import 'package:pokedex_app/core/network/guess_the_pokemon_api_client.dart';
import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/core/providers/package_info_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/datasources/guess_the_pokemon_local_datasource.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/datasources/guess_the_pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/repositories/guess_the_pokemon_repository_impl.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/repositories/guess_the_pokemon_repository.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/repositories/pokemon_repository_impl.dart';
import 'package:pokedex_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex_app/features/regions/data/datasources/region_local_datasource.dart';
import 'package:pokedex_app/features/regions/data/repositories/region_repository_impl.dart';
import 'package:pokedex_app/features/regions/domain/repositories/region_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main.dart');
});

final dioProvider = Provider<Dio>((ref) {
  final appVersion = ref.watch(packageInfoProvider).value?.version ?? '1.0.0';
  return createDio(
    connectivity: ref.watch(connectivityServiceProvider),
    appVersion: appVersion,
  );
});

final gameDioProvider = Provider<Dio>((ref) {
  return createDio(
    connectivity: ref.watch(connectivityServiceProvider),
    baseUrl: Env.gameApiBaseUrl,
    // PokéAPI client-id header is not needed here and breaks CORS preflight on web.
    headers: const {'Accept': 'application/json'},
    enableLogging: false,
  );
});

final gameAuthTokenProvider = Provider<GameAuthTokenProvider>((ref) {
  final firebase = ref.watch(firebaseBootstrapProvider);
  return ({required bool forceRefresh}) async {
    if (!firebase.isAvailable) return null;
    return FirebaseAuth.instance.currentUser?.getIdToken(forceRefresh);
  };
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final pokeApiClientProvider = Provider<PokeApiClient>(
  (ref) => PokeApiClient(ref.watch(dioProvider)),
);

final guessThePokemonApiClientProvider = Provider<GuessThePokemonApiClient>(
  (ref) => GuessThePokemonApiClient(
    ref.watch(gameDioProvider),
    tokenProvider: ref.watch(gameAuthTokenProvider),
  ),
);

final pokemonRemoteDataSourceProvider = Provider<PokemonRemoteDataSource>((
  ref,
) {
  return PokemonRemoteDataSource(ref.watch(pokeApiClientProvider));
});

final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  // ponytail: warmNameIndex is long-running; read deps + keepAlive avoid rebuild mid-flight.
  ref.keepAlive();

  final repository = PokemonRepositoryImpl(
    remote: ref.read(pokemonRemoteDataSourceProvider),
    local: PokemonLocalDataSource(ref.read(appDatabaseProvider)),
    gameTextResolver: ref.read(gameTextResolverProvider),
    initialLocale: ref.read(appLocaleProvider),
  );

  ref.listen<AppLocale>(appLocaleProvider, (previous, next) {
    if (previous != next) {
      repository.onLocaleChanged(next);
    }
  });

  return repository;
});

final regionRepositoryProvider = Provider<RegionRepository>((ref) {
  return RegionRepositoryImpl(
    client: ref.watch(pokeApiClientProvider),
    local: RegionLocalDataSource(ref.watch(appDatabaseProvider)),
  );
});

final guessThePokemonRemoteDataSourceProvider =
    Provider<GuessThePokemonRemoteDataSource>(
      (ref) => GuessThePokemonRemoteDataSource(
        ref.watch(guessThePokemonApiClientProvider),
      ),
    );

final guessThePokemonLocalDataSourceProvider =
    Provider<GuessThePokemonLocalDataSource>(
       (ref) {
         final auth = ref.watch(authProvider);
         final scopeKey = auth.isAuthenticated && auth.uid != null
             ? auth.uid!
             : 'guest';
         return GuessThePokemonLocalDataSource(
           ref.watch(sharedPreferencesProvider),
           scopeKey: scopeKey,
         );
       },
    );

final guessThePokemonRepositoryProvider = Provider<GuessThePokemonRepository>(
  (ref) => GuessThePokemonRepositoryImpl(
    local: ref.watch(guessThePokemonLocalDataSourceProvider),
    remote: ref.watch(guessThePokemonRemoteDataSourceProvider),
  ),
);
