import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_display_names.dart';

class PokemonMapper {
  static List<PokemonType> mapTypes(List<PokemonTypeSlot> slots) {
    return slots
        .map((slot) => PokemonType.fromApiName(slot.name))
        .whereType<PokemonType>()
        .toList();
  }

  static PokemonSummary toSummary(
    PokemonResponse response, {
    required String pokeApiCode,
    PokemonSpeciesResponse? species,
  }) {
    return PokemonSummary(
      id: response.id,
      slug: response.name,
      name: PokemonDisplayNames.resolve(
        apiName: response.name,
        speciesLocalizedName: species?.localizedName(pokeApiCode),
        isDefault: response.isDefault,
      ),
      types: mapTypes(response.types),
      spriteUrl: response.spriteUrl,
      height: response.height,
      weight: response.weight,
      isDefault: response.isDefault,
      isMega: response.isMega ?? false,
    );
  }

  static PokemonDetail toDetail(
    PokemonResponse response, {
    required String pokeApiCode,
    PokemonSpeciesResponse? species,
  }) {
    return PokemonDetail(
      id: response.id,
      name: PokemonDisplayNames.resolve(
        apiName: response.name,
        speciesLocalizedName: species?.localizedName(pokeApiCode),
        isDefault: response.isDefault,
      ),
      height: response.height,
      weight: response.weight,
      types: mapTypes(response.types),
      stats: response.stats
          .map((s) => PokemonStat(name: s.name, baseStat: s.baseStat))
          .toList(),
      abilities: response.abilities
          .map((a) => PokemonAbility(name: a.name, isHidden: a.isHidden))
          .toList(),
      spriteUrl: response.spriteUrl,
      cryUrl: response.cries.latest,
      legacyCryUrl: response.cries.legacy,
      flavorText: species?.localizedFlavorText(pokeApiCode),
      genderRate: species?.genderRate ?? -1,
      captureRate: species?.captureRate ?? 0,
      baseHappiness: species?.baseHappiness ?? 0,
      hatchCounter: species?.hatchCounter ?? 0,
      eggGroups: species?.eggGroups ?? const [],
      flavorTextEntries: species?.flavorTextEntries ?? const [],
      generaEntries: species?.genera ?? const [],
    );
  }
}
