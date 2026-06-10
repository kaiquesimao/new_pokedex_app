import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/features/regions/data/datasources/region_local_datasource.dart';
import 'package:pokedex_app/features/regions/data/repositories/region_repository_impl.dart';
import 'package:pokedex_app/features/regions/domain/entities/regional_pokedex_entry.dart';

class _FailingRegionClient implements PokeApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw const NetworkException('failed host lookup: pokeapi.co');
  }
}

void main() {
  late AppDatabase db;
  late RegionRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final local = RegionLocalDataSource(db);
    await local.saveRegionalEntries('kanto', const [
      RegionalPokedexEntry(
        entryNumber: 1,
        speciesId: 1,
        speciesName: 'bulbasaur',
      ),
    ]);
    repository = RegionRepositoryImpl(
      client: _FailingRegionClient(),
      local: local,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'getRegionalPokedexEntries falls back to cached entries when offline',
    () async {
      final entries = await repository.getRegionalPokedexEntries('kanto');

      expect(entries, hasLength(1));
      expect(entries.first.speciesName, 'bulbasaur');
      expect(repository.takeOfflineFallbackUsed(), isTrue);
    },
  );

  test('getRegionalPokedexEntries throws when offline without cache', () async {
    expect(
      () => repository.getRegionalPokedexEntries('johto'),
      throwsA(isA<OfflineEmptyCacheException>()),
    );
  });
}
