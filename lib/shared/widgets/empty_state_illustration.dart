import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/shared/widgets/trainer_avatar_image.dart';
import 'package:pokedex_app/shared/widgets/trainer_illustration_group.dart';

class const EmptyStateIllustration({
  required final String imageAsset,
  required final String title,
  super.key,
  final String? subtitle,
  final Widget? action,
  final bool pixelArt = false,
}) extends StatelessWidget {
  static const _illustrationSizeMobile = 220.0;
  static const _illustrationSizeWeb = 280.0;
  static const _illustrationSizeMin = 96.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxIllustration = kIsWeb
        ? _illustrationSizeWeb
        : _illustrationSizeMobile;

    // Fit inside shell body (nav clearance is parent padding) — no scroll bar.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final side = (constraints.maxHeight < constraints.maxWidth
                        ? constraints.maxHeight
                        : constraints.maxWidth)
                    .clamp(_illustrationSizeMin, maxIllustration);
                return Center(
                  child: pixelArt
                      ? TrainerIllustrationSlot(
                          assetPath: imageAsset,
                          slotSize: side,
                          errorBuilder: _errorBuilder(theme, side * 0.5),
                        )
                      : TrainerAvatarImage(
                          assetPath: imageAsset,
                          height: side,
                          pixelArt: false,
                          errorBuilder: _errorBuilder(theme, side * 0.45),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 20),
            action!,
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  ImageErrorWidgetBuilder _errorBuilder(ThemeData theme, double iconSize) {
    return (_, _, _) => Icon(
      Icons.image_not_supported_outlined,
      size: iconSize,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
    );
  }
}
