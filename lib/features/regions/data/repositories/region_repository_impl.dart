import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/features/regions/data/models/region_models.dart';
import 'package:pokedex_app/features/regions/domain/entities/regional_pokedex_entry.dart';
import 'package:pokedex_app/features/regions/domain/repositories/region_repository.dart';

class RegionRepositoryImpl implements RegionRepository {
  RegionRepositoryImpl({required this._client});

  final PokeApiClient _client;

  @override
  Future<List<NamedApiResource>> getRegions() async {
    final response = await _client.getRegions();
    return response.results;
  }

  @override
  Future<List<RegionalPokedexEntry>> getRegionalPokedexEntries(
    String regionName,
  ) async {
    final region = await _client.getRegion(regionName);
    if (region.pokedexes.isEmpty) return [];

    final pokedexId = region.pokedexes.first.id;
    if (pokedexId == null) return [];

    final pokedex = await _client.getPokedex(pokedexId);

    final entries = pokedex.pokemonEntries
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
        .toList();

    entries.sort((a, b) => a.entryNumber.compareTo(b.entryNumber));
    return entries;
  }
}
