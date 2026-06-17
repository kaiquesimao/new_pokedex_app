import 'dart:convert';

import 'package:pokedex_app/core/constants/pokemon_sprite_urls.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_ref.dart';

class PokemonLocalDataSource {
  PokemonLocalDataSource(this._db);

  final AppDatabase _db;

  Future<PokemonSummary?> getSummary(int id, {bool allowStale = false}) async {
    final entry = await _db.getEntry(id);
    if (entry == null) return null;
    if (!allowStale && !_db.isFresh(entry.cachedAt)) return null;

    return _entryToSummary(entry);
  }

  Future<List<PokemonSummary>> getSummaries(
    List<int> ids, {
    bool allowStale = false,
  }) async {
    final entries = await _db.getEntriesByIds(ids);
    return entries
        .where((e) => allowStale || _db.isFresh(e.cachedAt))
        .map(_entryToSummary)
        .toList();
  }

  Future<PokemonResponse?> getPokemonResponse(
    int id, {
    bool allowStale = false,
  }) async {
    final entry = await _db.getEntry(id);
    if (entry?.detailJson == null) return null;
    if (!allowStale && !_db.isFresh(entry!.cachedAt)) {
      return null;
    }
    return PokemonResponse.fromJson(
      jsonDecode(entry!.detailJson!) as Map<String, dynamic>,
    );
  }

  Future<int> countCachedSummaries() => _db.countCachedEntries();

  Future<bool> hasCachedData() async {
    return (await countCachedSummaries()) > 0;
  }

  Future<List<PokemonSummary>> getCachedSummariesPage({
    required int offset,
    required int limit,
  }) async {
    final entries = await _db.getCachedEntriesPage(
      offset: offset,
      limit: limit,
    );
    return entries.map(_entryToSummary).toList();
  }

  Future<List<int>> getAllCachedSummaryIds() => _db.getAllCachedEntryIds();

  Future<List<PokemonRef>> searchCachedRefsByName(String query) async {
    final rows = await _db.searchCachedEntriesByName(query);
    return rows.map((row) => PokemonRef(id: row.id, name: row.name)).toList();
  }

  Future<void> saveSummary(PokemonSummary summary) {
    return _db.upsertSummary(
      id: summary.id,
      name: summary.name,
      types: summary.types.map((t) => t.apiName).toList(),
      spriteUrl: summary.spriteUrl,
    );
  }

  Future<void> savePokemonResponse(PokemonResponse response) {
    return _db.upsertDetail(
      id: response.id,
      detailJson: jsonEncode(_responseToJson(response)),
    );
  }

  Future<void> replaceNameIndex(List<PokemonRef> refs) {
    return _db.replaceNameIndex(
      refs.map((ref) => (id: ref.id, name: ref.name)).toList(),
    );
  }

  Future<bool> isNameIndexReady() async {
    return (await _db.countNameIndex()) > 0;
  }

  Future<List<PokemonRef>> searchRefsByName(String query) async {
    final rows = await _db.searchIdsByName(query);
    return rows.map((row) => PokemonRef(id: row.id, name: row.name)).toList();
  }

  Future<List<PokemonRef>> getIndexedRefs() async {
    final rows = await _db.getAllIndexedRefs();
    return rows.map((row) => PokemonRef(id: row.id, name: row.name)).toList();
  }

  PokemonSummary _entryToSummary(CachedPokemonEntry entry) {
    final types = (jsonDecode(entry.typesJson) as List<dynamic>)
        .map((e) => e as String)
        .toList();

    int? height;
    int? weight;
    if (entry.detailJson != null) {
      final detail = jsonDecode(entry.detailJson!) as Map<String, dynamic>;
      height = detail['height'] as int?;
      weight = detail['weight'] as int?;
    }

    final spriteUrl = PokemonSpriteUrls.homeArtwork(pokemonId: entry.id);

    return PokemonSummary(
      id: entry.id,
      name: entry.name,
      types: types
          .map((name) => PokemonType.fromApiName(name))
          .whereType<PokemonType>()
          .toList(),
      spriteUrl: spriteUrl,
      height: height,
      weight: weight,
    );
  }

  Map<String, dynamic> _responseToJson(PokemonResponse response) {
    return {
      'id': response.id,
      'name': response.name,
      'height': response.height,
      'weight': response.weight,
      'sprites': {
        'front_default': response.spriteUrl,
        'other': {
          'home': {
            'front_default': response.spriteUrl,
            'back_default': response.spriteUrl,
          },
          'official-artwork': {'front_default': response.spriteUrl},
        },
      },
      'types': response.types
          .map(
            (t) => {
              'slot': t.slot,
              'type': {'name': t.name},
            },
          )
          .toList(),
      'stats': response.stats
          .map(
            (s) => {
              'base_stat': s.baseStat,
              'stat': {'name': s.name},
            },
          )
          .toList(),
      'abilities': response.abilities
          .map(
            (a) => {
              'is_hidden': a.isHidden,
              'ability': {'name': a.name},
            },
          )
          .toList(),
    };
  }
}
