import 'package:pokedex_app/core/constants/pokemon_types.dart';

/// Static type chart: types that deal double damage to [defender].
const Map<PokemonType, Set<PokemonType>> kTypeWeaknesses = {
  PokemonType.normal: {PokemonType.fighting},
  PokemonType.fire: {PokemonType.water, PokemonType.ground, PokemonType.rock},
  PokemonType.water: {PokemonType.electric, PokemonType.grass},
  PokemonType.grass: {
    PokemonType.fire,
    PokemonType.ice,
    PokemonType.poison,
    PokemonType.flying,
    PokemonType.bug,
  },
  PokemonType.electric: {PokemonType.ground},
  PokemonType.ice: {
    PokemonType.fire,
    PokemonType.fighting,
    PokemonType.rock,
    PokemonType.steel,
  },
  PokemonType.fighting: {
    PokemonType.flying,
    PokemonType.psychic,
    PokemonType.fairy,
  },
  PokemonType.poison: {PokemonType.ground, PokemonType.psychic},
  PokemonType.ground: {PokemonType.water, PokemonType.grass, PokemonType.ice},
  PokemonType.flying: {
    PokemonType.electric,
    PokemonType.ice,
    PokemonType.rock,
  },
  PokemonType.psychic: {
    PokemonType.bug,
    PokemonType.ghost,
    PokemonType.dark,
  },
  PokemonType.bug: {
    PokemonType.fire,
    PokemonType.flying,
    PokemonType.rock,
  },
  PokemonType.rock: {
    PokemonType.water,
    PokemonType.grass,
    PokemonType.fighting,
    PokemonType.ground,
    PokemonType.steel,
  },
  PokemonType.ghost: {PokemonType.ghost, PokemonType.dark},
  PokemonType.dragon: {
    PokemonType.ice,
    PokemonType.dragon,
    PokemonType.fairy,
  },
  PokemonType.dark: {
    PokemonType.fighting,
    PokemonType.bug,
    PokemonType.fairy,
  },
  PokemonType.steel: {
    PokemonType.fire,
    PokemonType.fighting,
    PokemonType.ground,
  },
  PokemonType.fairy: {PokemonType.poison, PokemonType.steel},
};

Set<PokemonType> weaknessesForTypes(List<PokemonType> types) {
  final result = <PokemonType>{};
  for (final type in types) {
    result.addAll(kTypeWeaknesses[type] ?? const {});
  }
  return result;
}
