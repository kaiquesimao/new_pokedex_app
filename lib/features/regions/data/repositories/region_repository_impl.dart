import 'package:pokedex_app/core/constants/region_card_assets.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/locale/offline_cache_error_kind.dart';
import 'package:pokedex_app/core/network/network_errors.dart';
import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/features/regions/data/datasources/region_local_datasource.dart';
import 'package:pokedex_app/features/regions/data/models/region_models.dart';
import 'package:pokedex_app/features/regions/domain/entities/regional_pokedex_entry.dart';
import 'package:pokedex_app/features/regions/domain/repositories/region_repository.dart';

class RegionRepositoryImpl implements RegionRepository {
  RegionRepositoryImpl({required this._client, required this._local});

  final PokeApiClient _client;
  final RegionLocalDataSource _local;
  bool _usedOfflineFallback = false;

  @override
  bool takeOfflineFallbackUsed() {
    final value = _usedOfflineFallback;
    _usedOfflineFallback = false;
    return value;
  }

  void _markOfflineFallback() {
    _usedOfflineFallback = true;
  }

  @override
  Future<List<NamedApiResource>> getRegions() async {
    try {
      final response = await _client.getRegions();
      return response.results;
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      _markOfflineFallback();
      return RegionCardAssets.curated
          .map(
            (region) => NamedApiResource(
              name: region.apiName,
              url: '/region/${region.apiName}/',
            ),
          )
          .toList();
    }
  }

  @override
  Future<List<RegionalPokedexEntry>> getRegionalPokedexEntries(
    String regionName,
  ) async {
    try {
      final entries = await _fetchRegionalPokedexEntries(regionName);
      await _local.saveRegionalEntries(regionName, entries);
      return entries;
    } catch (error) {
      if (!isNetworkError(error)) rethrow;
      _markOfflineFallback();

      final cached = await _local.getRegionalEntries(
        regionName,
        allowStale: true,
      );
      if (cached == null || cached.isEmpty) {
        throw OfflineEmptyCacheException(
          kind: OfflineCacheErrorKind.regionPokedexNotCached,
          regionName:
              RegionCardAssets.forApiName(regionName)?.displayName ??
              regionName,
        );
      }

      return cached;
    }
  }

  Future<List<RegionalPokedexEntry>> _fetchRegionalPokedexEntries(
    String regionName,
  ) async {
    final region = await _client.getRegion(regionName);
    if (region.pokedexes.isEmpty) return [];

    final pokedexId = region.pokedexes.first.id;
    if (pokedexId == null) return [];

    final pokedex = await _client.getPokedex(pokedexId);

    return pokedex.pokemonEntries
        .map((entry) {
          final speciesId = entry.pokemonSpecies.id;
          if (speciesId == null) return null;

          return RegionalPokedexEntry(
            entryNumber: entry.entryNumber,
            speciesId: speciesId,
            speciesName: entry.pokemonSpecies.name,
          );
        })
        .whereType<RegionalPokedexEntry>()
        .toList()
      ..sort((a, b) => a.entryNumber.compareTo(b.entryNumber));
  }
}
