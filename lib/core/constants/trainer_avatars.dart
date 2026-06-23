import 'package:flutter/foundation.dart';

abstract final class TrainerAvatars {
  static const String defaultSlug = 'hilbert';
  static const String assetsBase = 'assets/images/characters/';

  /// Sprite size after 4x nearest-neighbor upscale (original art was 80px).
  static const double sourceSpriteSize = 320;

  /// Fixed square slot when two or more trainers are shown side by side.
  static const double illustrationSlotSizeDual = 240;

  /// Fixed square slot when a single trainer is shown alone.
  static const double illustrationSlotSizeSingle = 224;

  static double illustrationSlotSize({required bool dual}) {
    return dual ? illustrationSlotSizeDual : illustrationSlotSizeSingle;
  }

  static double illustrationScaleFor(String assetPath) {
    for (final option in curated) {
      if (assetPath == option.assetPath) return option.illustrationScale;
    }
    return 1;
  }

  static const List<TrainerAvatarOption> curated = [
    TrainerAvatarOption(
      slug: 'hilbert',
      label: 'Hilbert',
      fileName: 'hilbert.png',
    ),
    TrainerAvatarOption(slug: 'hilda', label: 'Hilda', fileName: 'hilda.png'),
    TrainerAvatarOption(slug: 'blue', label: 'Blue', fileName: 'blue.png'),
    TrainerAvatarOption(
      slug: 'cynthia',
      label: 'Cynthia',
      fileName: 'cynthia.png',
    ),
    TrainerAvatarOption(
      slug: 'wallace',
      label: 'Wallace',
      fileName: 'wallace.png',
    ),
    TrainerAvatarOption(
      slug: 'wallace_gen6',
      label: 'Wallace',
      fileName: 'wallace-gen6.png',
    ),
    TrainerAvatarOption(
      slug: 'lucian',
      label: 'Lucian',
      fileName: 'lucian.png',
    ),
    TrainerAvatarOption(
      slug: 'victor',
      label: 'Victor',
      fileName: 'victor.png',
    ),
    TrainerAvatarOption(
      slug: 'birch',
      label: 'Prof. Birch',
      fileName: 'birch.png',
    ),
    TrainerAvatarOption(
      slug: 'bugcatcher',
      label: 'Caçador de Insetos',
      fileName: 'bugcatcher.png',
    ),
    TrainerAvatarOption(
      slug: 'pokemaniac',
      label: 'Pokémaníaco',
      fileName: 'pokemaniac.png',
    ),
    TrainerAvatarOption(
      slug: 'miku',
      label: 'Miku',
      fileName: 'miku.png',
      // Portrait asset fills the frame; standard sprites have padding.
      illustrationScale: kIsWeb ? 1 : 0.80,
    ),
  ];

  static String assetPathFor(String slug) {
    final match = curated.where((option) => option.slug == slug);
    if (match.isNotEmpty) return match.first.assetPath;
    return curated.first.assetPath;
  }

  static String labelFor(String slug) {
    final match = curated.where((option) => option.slug == slug);
    if (match.isNotEmpty) return match.first.label;
    return curated.first.label;
  }
}

class TrainerAvatarOption {
  const TrainerAvatarOption({
    required this.slug,
    required this.label,
    required this.fileName,
    this.illustrationScale = 1,
  });

  final String slug;
  final String label;
  final String fileName;

  /// Visual scale for character normalization (1 = default sprite framing).
  final double illustrationScale;

  String get assetPath => '${TrainerAvatars.assetsBase}$fileName';
}
