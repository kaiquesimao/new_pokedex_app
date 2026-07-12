/// One visual option in the detail-page sprite carousel.
class PokemonSpriteVariant {
  const PokemonSpriteVariant({
    required this.imageUrl,
    required this.pokemonId,
    required this.labelKey,
    this.isShiny = false,
  });

  final String imageUrl;
  final int pokemonId;

  /// Stable key resolved via PokemonSpriteVariantLabels / l10n.
  final String labelKey;
  final bool isShiny;
}
