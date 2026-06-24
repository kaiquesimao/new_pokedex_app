import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/shared/widgets/trainer_avatar_image.dart';

enum TrainerIllustrationLayout { auto, single, dual }

double dualIllustrationWidthCap(double maxWidth, int assetCount) {
  if (assetCount <= 1) return maxWidth;

  const edgePadding = TrainerAvatars.illustrationDualEdgePadding;
  final usableWidth = maxWidth - edgePadding * 2;

  const spanFactor =
      TrainerAvatars.illustrationDualOpaqueWidthFraction +
      2 * TrainerAvatars.illustrationDualCenterShift;
  return usableWidth / spanFactor;
}

double resolveIllustrationSlotSize({
  required bool dual,
  required BoxConstraints constraints,
  required int assetCount,
  required Size viewportSize,
}) {
  final slotWidth = dual
      ? constraints.maxWidth / assetCount
      : constraints.maxWidth;

  final availableHeight = constraints.maxHeight.isFinite
      ? constraints.maxHeight
      : viewportSize.height *
            (dual
                ? TrainerAvatars.illustrationViewportFallbackDual
                : TrainerAvatars.illustrationViewportFallbackSingle);

  final heightFactor = dual
      ? TrainerAvatars.illustrationHeightFactorDual
      : TrainerAvatars.illustrationHeightFactorSingle;
  final widthFactor = dual
      ? TrainerAvatars.illustrationWidthFactorDual
      : TrainerAvatars.illustrationWidthFactorSingle;

  final fromHeight = availableHeight * heightFactor;
  final fromWidth = slotWidth * widthFactor;
  final min = dual
      ? TrainerAvatars.illustrationSlotMinDual
      : TrainerAvatars.illustrationSlotMinSingle;
  final max = dual
      ? TrainerAvatars.illustrationSlotMaxDual
      : TrainerAvatars.illustrationSlotMaxSingle;

  if (dual) {
    var size = fromHeight;
    if (availableHeight < size) size = availableHeight;
    if (assetCount > 1) {
      final widthCap = dualIllustrationWidthCap(viewportSize.width, assetCount);
      if (size > widthCap) size = widthCap;
      final effectiveMin = min <= widthCap ? min : widthCap;
      return size.clamp(effectiveMin, max) *
          TrainerAvatars.illustrationDualSizeScale;
    }
    return size.clamp(min, max) * TrainerAvatars.illustrationDualSizeScale;
  }

  var size = fromHeight < fromWidth ? fromHeight : fromWidth;
  if (availableHeight < size) size = availableHeight;
  if (slotWidth < size) size = slotWidth;

  return size.clamp(min, max);
}

/// Lays out one or more trainer sprites in responsive square slots.
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
    final viewportSize = MediaQuery.sizeOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final slotSize = resolveIllustrationSlotSize(
          dual: isDual,
          constraints: constraints,
          assetCount: imageAssets.length,
          viewportSize: viewportSize,
        );
        final slotWidth = isDual
            ? constraints.maxWidth / imageAssets.length
            : constraints.maxWidth;

        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : slotSize;

        return SizedBox(
          height: height,
          width: constraints.maxWidth,
          child: isDual
              ? OverflowBox(
                  maxWidth: viewportSize.width,
                  child: SizedBox(
                    width: viewportSize.width,
                    child: _DualIllustrationStack(
                      imageAssets: imageAssets,
                      slotSize: slotSize,
                      errorBuilder: errorBuilder,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < imageAssets.length; i++)
                      SizedBox(
                        width: slotWidth,
                        height: slotSize,
                        child: TrainerIllustrationSlot(
                          assetPath: imageAssets[i],
                          slotSize: slotSize,
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
}

class _DualIllustrationStack extends StatelessWidget {
  const _DualIllustrationStack({
    required this.imageAssets,
    required this.slotSize,
    this.errorBuilder,
  });

  final List<String> imageAssets;
  final double slotSize;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final shift = slotSize * TrainerAvatars.illustrationDualCenterShift;
    final step = imageAssets.length > 1 ? imageAssets.length - 1 : 1;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        for (var i = 0; i < imageAssets.length; i++)
          Transform.translate(
            offset: Offset((i / step - 0.5) * 2 * shift, 0),
            child: TrainerIllustrationSlot(
              assetPath: imageAssets[i],
              slotSize: slotSize,
              alignment: i == 0 ? Alignment.centerRight : Alignment.centerLeft,
              errorBuilder: errorBuilder,
            ),
          ),
      ],
    );
  }
}

class TrainerIllustrationSlot extends StatelessWidget {
  const TrainerIllustrationSlot({
    required this.assetPath,
    super.key,
    this.slotSize,
    this.dual = false,
    this.alignment = Alignment.center,
    this.errorBuilder,
  });

  final String assetPath;
  final double? slotSize;
  final bool dual;
  final Alignment alignment;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (slotSize != null) {
      return _buildSlot(slotSize!);
    }

    final viewportSize = MediaQuery.sizeOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedSize = resolveIllustrationSlotSize(
          dual: dual,
          constraints: constraints,
          assetCount: 1,
          viewportSize: viewportSize,
        );
        return _buildSlot(resolvedSize);
      },
    );
  }

  Widget _buildSlot(double size) {
    final characterScale = TrainerAvatars.illustrationScaleFor(assetPath);

    return SizedBox(
      width: size,
      height: size,
      child: Align(
        alignment: alignment,
        child: Transform.scale(
          scale: characterScale,
          alignment: alignment,
          child: TrainerAvatarImage(
            assetPath: assetPath,
            width: size,
            height: size,
            alignment: alignment,
            errorBuilder: errorBuilder,
          ),
        ),
      ),
    );
  }
}
