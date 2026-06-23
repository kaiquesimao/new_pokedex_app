import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/shared/widgets/trainer_avatar_image.dart';

enum TrainerIllustrationLayout { auto, single, dual }

/// Lays out one or more trainer sprites in fixed square slots so characters
/// appear at a consistent size (dual vs single layouts use different slot sizes).
class TrainerIllustrationGroup extends StatelessWidget {
  const TrainerIllustrationGroup({
    required this.imageAssets,
    super.key,
    this.layout = TrainerIllustrationLayout.auto,
    this.errorBuilder,
  });

  final List<String> imageAssets;
  final TrainerIllustrationLayout layout;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final resolvedLayout = _resolveLayout();
    final isDual = resolvedLayout == TrainerIllustrationLayout.dual;
    final slotSize = TrainerAvatars.illustrationSlotSize(dual: isDual);

    return LayoutBuilder(
      builder: (context, constraints) {
        final slotWidth = isDual
            ? constraints.maxWidth / imageAssets.length
            : constraints.maxWidth;

        return SizedBox(
          height: slotSize,
          width: constraints.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < imageAssets.length; i++)
                SizedBox(
                  width: slotWidth,
                  child: TrainerIllustrationSlot(
                    assetPath: imageAssets[i],
                    slotSize: slotSize,
                    alignment: _alignmentForIndex(i, isDual),
                    errorBuilder: errorBuilder,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  TrainerIllustrationLayout _resolveLayout() {
    if (layout != TrainerIllustrationLayout.auto) return layout;
    return imageAssets.length > 1
        ? TrainerIllustrationLayout.dual
        : TrainerIllustrationLayout.single;
  }

  Alignment _alignmentForIndex(int index, bool isDual) {
    if (!isDual) return Alignment.center;
    return index == 0 ? Alignment.centerRight : Alignment.centerLeft;
  }
}

class TrainerIllustrationSlot extends StatelessWidget {
  const TrainerIllustrationSlot({
    required this.assetPath,
    required this.slotSize,
    super.key,
    this.alignment = Alignment.center,
    this.errorBuilder,
  });

  final String assetPath;
  final double slotSize;
  final Alignment alignment;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final characterScale = TrainerAvatars.illustrationScaleFor(assetPath);

    return SizedBox(
      width: slotSize,
      height: slotSize,
      child: Align(
        alignment: alignment,
        child: Transform.scale(
          scale: characterScale,
          alignment: alignment,
          child: TrainerAvatarImage(
            assetPath: assetPath,
            width: slotSize,
            height: slotSize,
            alignment: alignment,
            errorBuilder: errorBuilder,
          ),
        ),
      ),
    );
  }
}
