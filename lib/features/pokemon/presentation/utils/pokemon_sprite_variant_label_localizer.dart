import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_sprite_variant_labels.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// Resolves carousel form labels through app localizations.
abstract final class PokemonSpriteVariantLabelLocalizer {
  static String label(AppLocalizations l10n, String labelKey) {
    return switch (labelKey) {
      PokemonSpriteVariantLabelKeys.normal => l10n.pokemonFormLabelNormal,
      PokemonSpriteVariantLabelKeys.shiny => l10n.pokemonFormLabelShiny,
      PokemonSpriteVariantLabelKeys.mega => l10n.pokemonFormLabelMega,
      PokemonSpriteVariantLabelKeys.megaX => l10n.pokemonFormLabelMegaX,
      PokemonSpriteVariantLabelKeys.megaY => l10n.pokemonFormLabelMegaY,
      PokemonSpriteVariantLabelKeys.alola => l10n.pokemonFormLabelAlola,
      PokemonSpriteVariantLabelKeys.galar => l10n.pokemonFormLabelGalar,
      PokemonSpriteVariantLabelKeys.hisui => l10n.pokemonFormLabelHisui,
      PokemonSpriteVariantLabelKeys.paldea => l10n.pokemonFormLabelPaldea,
      PokemonSpriteVariantLabelKeys.gigantamax =>
        l10n.pokemonFormLabelGigantamax,
      _ => PokemonSpriteVariantLabels.titleCaseFallback(labelKey),
    };
  }
}
