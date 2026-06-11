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
  static const int compact = 144;
  static const int listRow = 216;
  static const int detail = 420;
  static const int evolution = 216;
}
