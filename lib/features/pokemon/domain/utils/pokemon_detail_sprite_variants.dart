import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_sprite_variant.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_form_visibility.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_sprite_variant_labels.dart';

/// Builds the ordered list of detail hero sprite variants.
///
/// Order: current form → shiny (same id) → other visible varieties.
/// Variants without an image URL are omitted. Returns empty when the current
/// form has no sprite (caller should show the placeholder).
List<PokemonSpriteVariant> buildPokemonDetailSpriteVariants({
  required int currentPokemonId,
  required String? currentSpriteUrl,
  required String? currentShinySpriteUrl,
  required List<PokemonSummary> varietySummaries,
  required PokemonFormVisibility visibility,
}) {
  if (currentSpriteUrl == null || currentSpriteUrl.isEmpty) {
    return const [];
  }

  final currentSummary = _findSummary(varietySummaries, currentPokemonId);
  final currentLabelKey = currentSummary != null
      ? PokemonSpriteVariantLabels.keyForSummary(currentSummary)
      : PokemonSpriteVariantLabelKeys.normal;

  final variants = <PokemonSpriteVariant>[
    PokemonSpriteVariant(
      imageUrl: currentSpriteUrl,
      pokemonId: currentPokemonId,
      labelKey: currentLabelKey,
    ),
  ];

  if (currentShinySpriteUrl != null && currentShinySpriteUrl.isNotEmpty) {
    variants.add(
      PokemonSpriteVariant(
        imageUrl: currentShinySpriteUrl,
        pokemonId: currentPokemonId,
        labelKey: PokemonSpriteVariantLabelKeys.shiny,
        isShiny: true,
      ),
    );
  }

  for (final summary in varietySummaries) {
    if (summary.id == currentPokemonId) continue;
    if (!visibility.includesSummary(summary)) continue;
    final spriteUrl = summary.spriteUrl;
    if (spriteUrl == null || spriteUrl.isEmpty) continue;

    variants.add(
      PokemonSpriteVariant(
        imageUrl: spriteUrl,
        pokemonId: summary.id,
        labelKey: PokemonSpriteVariantLabels.keyForSummary(summary),
      ),
    );
  }

  return variants;
}

PokemonSummary? _findSummary(List<PokemonSummary> summaries, int pokemonId) {
  for (final summary in summaries) {
    if (summary.id == pokemonId) return summary;
  }
  return null;
}
