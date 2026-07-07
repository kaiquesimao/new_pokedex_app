import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/data/repositories/pokemon_repository_impl.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';

class _FailingRemoteDataSource extends PokemonRemoteDataSource {
  _FailingRemoteDataSource() : super(_ThrowingClient());

  @override
  Future<PokemonListResponse> fetchPokemonList({
    int offset = 0,
    int limit = 20,
  }) {
    throw const NetworkException();
  }
}

class _ThrowingClient implements PokeApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw const NetworkException();
  }
}

void main() {
  late AppDatabase db;
  late PokemonRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final local = PokemonLocalDataSource(db);
    await local.saveSummary(
      const PokemonSummary(
        id: 25,
        slug: 'pikachu',
        name: 'pikachu',
        types: [],
        spriteUrl: 'https://example.com/pikachu.png',
      ),
    );
    repository = PokemonRepositoryImpl(
      remote: _FailingRemoteDataSource(),
      local: local,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'getPokemonListSlice falls back to cached summaries when offline',
    () async {
      final slice = await repository.getPokemonListSlice(offset: 0);

      expect(slice.fromCache, isTrue);
      expect(slice.ids, [25]);
      expect(slice.totalCount, 1);
      expect(repository.takeOfflineFallbackUsed(), isTrue);
    },
  );

  test('getPokemonListSlice throws when offline with empty cache', () async {
    await db.delete(db.cachedPokemonEntries).go();

    expect(
      () => repository.getPokemonListSlice(offset: 0),
      throwsA(isA<OfflineEmptyCacheException>()),
    );
  });

  test('getSummaryById returns cached data when offline', () async {
    final summary = await repository.getSummaryById(25);

    expect(summary.name, 'pikachu');
  });
}
