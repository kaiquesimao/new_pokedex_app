import 'package:flutter/material.dart';

/// Shared shimmer palette so loading placeholders stay visible in both themes.
///
/// Uses [ColorScheme.surface] blended with [ColorScheme.onSurface] so base
/// bars read clearly on scaffold backgrounds and the highlight sweeps in a
/// visibly different direction (lighter grey) in light and dark mode.
abstract final class SkeletonShimmerColors {
  const SkeletonShimmerColors._();

  /// Darker (light) / lighter (dark) grey for bones and shimmer base.
  static Color base(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return Color.lerp(
      scheme.surface,
      scheme.onSurface,
      isDark ? 0.18 : 0.14,
    )!;
  }

  /// Sweep highlight — always lighter than [base] relative to content.
  static Color highlight(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return Color.lerp(
      scheme.surface,
      scheme.onSurface,
      isDark ? 0.32 : 0.05,
    )!;
  }

  /// Soft card/row fill (stronger than a raw low-alpha surface tint).
  static Color softFill(BuildContext context) =>
      base(context).withValues(alpha: 0.55);
}
