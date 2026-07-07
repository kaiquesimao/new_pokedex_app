import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class CachedPokemonEntries extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get typesJson => text()();
  TextColumn get spriteUrl => text().nullable()();
  TextColumn get detailJson => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PokemonNameIndex extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get localizedName => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedRegionalPokedexEntries extends Table {
  TextColumn get regionName => text()();
  TextColumn get entriesJson => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {regionName};
}

@DriftDatabase(
  tables: [
    CachedPokemonEntries,
    PokemonNameIndex,
    CachedRegionalPokedexEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  // Schema version and migration updated to v4 (adds localizedName).
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(pokemonNameIndex);
      }
      if (from < 3) {
        await migrator.createTable(cachedRegionalPokedexEntries);
      }
      if (from < 4) {
        // Add localizedName column with default empty string.
        await migrator.addColumn(
          pokemonNameIndex,
          pokemonNameIndex.localizedName,
        );
      }
    },
  );

  static const Duration cacheTtl = Duration(days: 7);

  Future<void> upsertSummary({
    required int id,
    required String name,
    required List<String> types,
    String? spriteUrl,
  }) async {
    final existing = await (select(
      cachedPokemonEntries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    await into(cachedPokemonEntries).insertOnConflictUpdate(
      CachedPokemonEntriesCompanion(
        id: Value(id),
        name: Value(name),
        typesJson: Value(jsonEncode(types)),
        spriteUrl: Value(spriteUrl),
        detailJson: Value(existing?.detailJson),
        cachedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> upsertDetail({
    required int id,
    required String detailJson,
  }) async {
    final existing = await (select(
      cachedPokemonEntries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    await into(cachedPokemonEntries).insertOnConflictUpdate(
      CachedPokemonEntriesCompanion(
        id: Value(id),
        name: Value(existing?.name ?? ''),
        typesJson: Value(existing?.typesJson ?? '[]'),
        spriteUrl: Value(existing?.spriteUrl),
        detailJson: Value(detailJson),
        cachedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<CachedPokemonEntry?> getEntry(int id) {
    return (select(
      cachedPokemonEntries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<CachedPokemonEntry>> getEntriesByIds(List<int> ids) {
    if (ids.isEmpty) return Future.value([]);
    return (select(cachedPokemonEntries)..where((t) => t.id.isIn(ids))).get();
  }

  Future<List<CachedPokemonEntry>> getCachedEntriesPage({
    required int offset,
    required int limit,
  }) {
    return (select(cachedPokemonEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<int> countCachedEntries() async {
    final countExp = cachedPokemonEntries.id.count();
    final query = selectOnly(cachedPokemonEntries)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<List<CachedPokemonEntry>> searchCachedEntriesByName(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return Future.value([]);

    return (select(
      cachedPokemonEntries,
    )..where((t) => t.name.lower().like('%$normalized%'))).get();
  }

  Future<List<int>> getAllCachedEntryIds() async {
    final rows = await select(cachedPokemonEntries).get();
    final ids = rows.map((row) => row.id).toList()..sort();
    return ids;
  }

  Future<void> replaceNameIndex(
    List<({int id, String name, String localizedName})> entries,
  ) async {
    await transaction(() async {
      await delete(pokemonNameIndex).go();
      if (entries.isEmpty) return;

      await batch((batch) {
        batch.insertAll(
          pokemonNameIndex,
          entries
              .map(
                (entry) => PokemonNameIndexCompanion.insert(
                  id: Value(entry.id),
                  name: entry.name,
                  localizedName: Value(entry.localizedName),
                ),
              )
              .toList(),
        );
      });
    });
  }

  Future<int> countNameIndex() async {
    final countExp = pokemonNameIndex.id.count();
    final query = selectOnly(pokemonNameIndex)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<List<PokemonNameIndexData>> searchIdsByName(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return Future.value([]);

    return (select(
          pokemonNameIndex,
        )..where(
          (t) =>
              t.name.lower().like('%$normalized%') |
              t.localizedName.lower().like('%$normalized%'),
        ))
        .get();
  }

  Future<List<PokemonNameIndexData>> getAllIndexedRefs() {
    return select(pokemonNameIndex).get();
  }

  bool isFresh(DateTime cachedAt) {
    return DateTime.now().difference(cachedAt) < cacheTtl;
  }

  Future<void> upsertRegionalPokedex({
    required String regionName,
    required String entriesJson,
  }) {
    return into(cachedRegionalPokedexEntries).insertOnConflictUpdate(
      CachedRegionalPokedexEntriesCompanion(
        regionName: Value(regionName),
        entriesJson: Value(entriesJson),
        cachedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<CachedRegionalPokedexEntry?> getRegionalPokedex(String regionName) {
    return (select(
      cachedRegionalPokedexEntries,
    )..where((t) => t.regionName.equals(regionName))).getSingleOrNull();
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'pokedex_cache',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
