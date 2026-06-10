import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';

class PokemonMapper {
  static List<PokemonType> mapTypes(List<PokemonTypeSlot> slots) {
    return slots
        .map((slot) => PokemonType.fromApiName(slot.name))
        .whereType<PokemonType>()
        .toList();
  }

  static PokemonSummary toSummary(PokemonResponse response) {
    return PokemonSummary(
      id: response.id,
      name: response.name,
      types: mapTypes(response.types),
      spriteUrl: response.listSpriteUrl ?? response.spriteUrl,
      height: response.height,
      weight: response.weight,
    );
  }

  static PokemonDetail toDetail(
    PokemonResponse response, {
    PokemonSpeciesResponse? species,
  }) {
    return PokemonDetail(
      id: response.id,
      name: response.name,
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
      flavorText: species?.flavorText,
      genderRate: species?.genderRate ?? -1,
      captureRate: species?.captureRate ?? 0,
      baseHappiness: species?.baseHappiness ?? 0,
      hatchCounter: species?.hatchCounter ?? 0,
      eggGroups: species?.eggGroups ?? const [],
    );
  }
}
