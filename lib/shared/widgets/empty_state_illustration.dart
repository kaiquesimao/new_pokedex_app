import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pokedex_app/shared/widgets/trainer_avatar_image.dart';
import 'package:pokedex_app/shared/widgets/trainer_illustration_group.dart';

class EmptyStateIllustration extends StatelessWidget {
  const EmptyStateIllustration({
    required this.imageAsset,
    required this.title,
    super.key,
    this.subtitle,
    this.action,
    this.pixelArt = false,
  });

  final String imageAsset;
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool pixelArt;

  static const _illustrationSizeMobile = 260.0;
  static const _illustrationSizeWeb = 320.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const illustrationSize = kIsWeb
        ? _illustrationSizeWeb
        : _illustrationSizeMobile;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (pixelArt)
            TrainerIllustrationSlot(
              assetPath: imageAsset,
              slotSize: illustrationSize,
              errorBuilder: _errorBuilder(theme, illustrationSize * 0.5),
            )
          else
            TrainerAvatarImage(
              assetPath: imageAsset,
              height: illustrationSize,
              pixelArt: false,
              errorBuilder: _errorBuilder(theme, illustrationSize * 0.45),
            ),
          const SizedBox(height: 28),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[const SizedBox(height: 28), action!],
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
