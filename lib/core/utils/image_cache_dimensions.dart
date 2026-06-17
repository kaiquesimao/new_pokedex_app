/// Computes the physical pixel size to use for [CachedNetworkImage] memory cache.
///
/// Returns `null` when [logicalSize] is not positive.
int? cachePixelSize(
  double logicalSize,
  double devicePixelRatio, {
  int maxPixels = 256,
}) {
  if (logicalSize <= 0) return null;
  final physical = (logicalSize * devicePixelRatio).ceil();
  return physical.clamp(1, maxPixels);
}

/// Preset cache caps for common Pokémon sprite display contexts.
abstract final class PokemonSpriteCachePresets {
  static const int compact = 192;
  static const int listRow = 288;
  static const int detail = 540;
  static const int evolution = 288;
}

/// Logical display sizes for Pokémon sprites across the app.
abstract final class PokemonSpriteDisplaySizes {
  static const double listRow = 96;
  static const double listCard = 96;
  static const double detail = 180;
  static const double evolution = 96;
  static const double regionStarter = 60;
}

/// Layout dimensions that frame Pokémon sprite images.
abstract final class PokemonSpriteLayoutSizes {
  static const double listRowHeight = 128;
  static const double listRowPanelWidth = 148;
  static const double detailHeaderHeight = 320;
  static const double detailCircleSize = 240;
  static const double evolutionCardWidth = 136;
}
