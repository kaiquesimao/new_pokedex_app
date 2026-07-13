import 'package:flutter/material.dart';
import 'package:pokedex_app/core/theme/skeleton_shimmer_colors.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:shimmer/shimmer.dart';

class PokemonListRowSkeleton extends StatelessWidget {
  const PokemonListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = SkeletonShimmerColors.base(context);
    final highlight = SkeletonShimmerColors.highlight(context);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: SizedBox(
        height: PokemonSpriteLayoutSizes.listRowHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SkeletonShimmerColors.softFill(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Bone(width: 44, height: 12, color: base),
                      const SizedBox(height: 8),
                      _Bone(width: 120, height: 16, color: base),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _Bone(
                            width: 56,
                            height: 22,
                            color: base,
                            radius: 11,
                          ),
                          const SizedBox(width: 6),
                          _Bone(
                            width: 56,
                            height: 22,
                            color: base,
                            radius: 11,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(16),
                ),
                child: ColoredBox(
                  color: base,
                  child: const SizedBox(
                    width: PokemonSpriteLayoutSizes.listRowPanelWidth,
                    height: PokemonSpriteLayoutSizes.listRowHeight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 4,
  });

  final double width;
  final double height;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
