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

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CachedPokemonEntries, PokemonNameIndex])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(pokemonNameIndex);
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

  Future<void> replaceNameIndex(List<({int id, String name})> entries) async {
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
    )..where((t) => t.name.lower().like('%$normalized%'))).get();
  }

  Future<List<PokemonNameIndexData>> getAllIndexedRefs() {
    return select(pokemonNameIndex).get();
  }

  bool isFresh(DateTime cachedAt) {
    return DateTime.now().difference(cachedAt) < cacheTtl;
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'pokedex_cache',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
