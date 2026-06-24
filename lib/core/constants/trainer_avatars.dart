import 'package:flutter/foundation.dart';

abstract final class TrainerAvatars {
  static const String defaultSlug = 'hilbert';
  static const String assetsBase = 'assets/images/characters/';

  /// Sprite size after 4x nearest-neighbor upscale (original art was 80px).
  static const double sourceSpriteSize = 320;

  /// Lower bounds when space is tight (e.g. small phones).
  static const double illustrationSlotMinDual = 300;
  static const double illustrationSlotMinSingle = 260;

  /// Upper bounds on very large screens.
  static const double illustrationSlotMaxDual = 520;
  static const double illustrationSlotMaxSingle = 400;

  /// Fraction of available height used per layout (dual fills more).
  static const double illustrationHeightFactorDual = 0.95;
  static const double illustrationHeightFactorSingle = 0.82;

  /// Fraction of slot width used as the square size cap.
  static const double illustrationWidthFactorDual = 1;
  static const double illustrationWidthFactorSingle = 0.72;

  /// Fallback when parent height is unbounded (scroll views, columns).
  static const double illustrationViewportFallbackDual = 0.45;
  static const double illustrationViewportFallbackSingle = 0.40;

  /// How far each dual sprite shifts toward the center (fraction of slot size).
  static const double illustrationDualCenterShift = 0.30;

  /// Approx. opaque width of sprite assets used for horizontal fit budgeting.
  static const double illustrationDualOpaqueWidthFraction = 0.55;

  /// Horizontal inset so dual sprites do not clip at screen edges.
  static const double illustrationDualEdgePadding = 8;

  /// Global scale applied to dual illustration size (1 = default).
  static const double illustrationDualSizeScale = 0.95;

  static double illustrationSlotSize({required bool dual}) {
    return dual ? illustrationSlotMinDual : illustrationSlotMinSingle;
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
      illustrationScale: kIsWeb ? 1 : 0.90,
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
