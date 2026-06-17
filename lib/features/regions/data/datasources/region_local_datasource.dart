import 'dart:convert';

import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/features/regions/domain/entities/regional_pokedex_entry.dart';

class RegionLocalDataSource {
  RegionLocalDataSource(this._db);

  final AppDatabase _db;

  Future<void> saveRegionalEntries(
    String regionName,
    List<RegionalPokedexEntry> entries,
  ) {
    final payload = entries
        .map(
          (entry) => {
            'entryNumber': entry.entryNumber,
            'speciesId': entry.speciesId,
            'speciesName': entry.speciesName,
          },
        )
        .toList();

    return _db.upsertRegionalPokedex(
      regionName: regionName,
      entriesJson: jsonEncode(payload),
    );
  }

  Future<List<RegionalPokedexEntry>?> getRegionalEntries(
    String regionName, {
    bool allowStale = false,
  }) async {
    final row = await _db.getRegionalPokedex(regionName);
    if (row == null) return null;
    if (!allowStale && !_db.isFresh(row.cachedAt)) return null;

    final decoded = jsonDecode(row.entriesJson) as List<dynamic>;
    return decoded.map(
      (item) {
        final map = item as Map<String, dynamic>;
        return RegionalPokedexEntry(
          entryNumber: map['entryNumber'] as int,
          speciesId: map['speciesId'] as int,
          speciesName: map['speciesName'] as String,
        );
      },
    ).toList();
  }
}
