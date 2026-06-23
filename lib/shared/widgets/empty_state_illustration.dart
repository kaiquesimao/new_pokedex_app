import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/shared/widgets/trainer_avatar_image.dart';
import 'package:pokedex_app/shared/widgets/trainer_illustration_group.dart';

class EmptyStateIllustration extends StatelessWidget {
  const EmptyStateIllustration({
    required this.imageAsset,
    required this.title,
    super.key,
    this.subtitle,
    this.action,
    this.imageHeight = TrainerAvatars.illustrationSlotSizeSingle,
    this.pixelArt = false,
  });

  final String imageAsset;
  final String title;
  final String? subtitle;
  final Widget? action;
  final double imageHeight;
  final bool pixelArt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (pixelArt)
            TrainerIllustrationSlot(
              assetPath: imageAsset,
              slotSize: imageHeight,
              errorBuilder: _errorBuilder(theme),
            )
          else
            TrainerAvatarImage(
              assetPath: imageAsset,
              height: imageHeight,
              pixelArt: false,
              errorBuilder: _errorBuilder(theme),
            ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    );
  }

  ImageErrorWidgetBuilder _errorBuilder(ThemeData theme) {
    return (_, _, _) => Icon(
      Icons.image_not_supported_outlined,
      size: imageHeight * 0.5,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
    );
  }
}
