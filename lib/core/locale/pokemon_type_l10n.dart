import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

extension PokemonTypeL10n on PokemonType {
  String label(AppLocalizations l10n) => switch (this) {
    PokemonType.normal => l10n.typeNormal,
    PokemonType.fire => l10n.typeFire,
    PokemonType.water => l10n.typeWater,
    PokemonType.grass => l10n.typeGrass,
    PokemonType.electric => l10n.typeElectric,
    PokemonType.ice => l10n.typeIce,
    PokemonType.fighting => l10n.typeFighting,
    PokemonType.poison => l10n.typePoison,
    PokemonType.ground => l10n.typeGround,
    PokemonType.flying => l10n.typeFlying,
    PokemonType.psychic => l10n.typePsychic,
    PokemonType.bug => l10n.typeBug,
    PokemonType.rock => l10n.typeRock,
    PokemonType.ghost => l10n.typeGhost,
    PokemonType.dragon => l10n.typeDragon,
    PokemonType.dark => l10n.typeDark,
    PokemonType.steel => l10n.typeSteel,
    PokemonType.fairy => l10n.typeFairy,
  };
}
