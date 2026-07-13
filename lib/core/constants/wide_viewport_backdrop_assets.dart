import 'package:pokedex_app/core/constants/region_card_assets.dart';

/// Local artwork used as a full-viewport backdrop on wide web layouts.
abstract final class WideViewportBackdropAssets {
  static final List<String> paths = [
    for (final region in RegionCardAssets.curated)
      if (region.landscapeAsset != null) region.landscapeAsset!,
  ];
}
