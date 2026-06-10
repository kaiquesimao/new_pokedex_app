import 'package:pokedex_app/features/regions/data/models/region_models.dart';
import 'package:pokedex_app/features/regions/domain/entities/regional_pokedex_entry.dart';

abstract class RegionRepository {
  Future<List<NamedApiResource>> getRegions();

  Future<List<RegionalPokedexEntry>> getRegionalPokedexEntries(
    String regionName,
  );
}
