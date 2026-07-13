import 'package:flutter/material.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';

/// Opaque surface chrome for content blocks on the Pokémon detail page.
class DetailSurfaceCard extends StatelessWidget {
  const DetailSurfaceCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.width = double.infinity,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;

  /// Section title style shared across the Pokémon detail page.
  static TextStyle? titleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
  }

  /// Body / value style matching the flavor description.
  static TextStyle? bodyStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      height: 1.4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? theme.dividerColor
        : AppColorsLight.textSecondary.withValues(alpha: 0.25);

    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
