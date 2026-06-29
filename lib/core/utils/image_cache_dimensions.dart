import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage;

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
  static const double listRowHeight = 150;
  static const double listRowPanelWidth = 120;
  static const double detailHeaderHeight = 320;
  static const double detailHeroTopInset = 48;
  static const double detailHeaderCircleDiameter = 320;

  /// Type icon occupies this fraction of the header circle diameter.
  static const double detailTypeIconScale = 0.70;

  static double detailTypeIconSize(double circleDiameter) =>
      circleDiameter * detailTypeIconScale;

  /// Top offset that vertically centers the header circle in the sprite area.
  static double detailHeaderCircleTop(double headerHeight) =>
      detailHeroTopInset +
      (headerHeight - detailHeroTopInset - detailHeaderCircleDiameter) / 2;
  static const double evolutionCardWidth = 136;
}
