import 'package:flutter/material.dart';
import 'package:pokedex_app/core/theme/skeleton_shimmer_colors.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:shimmer/shimmer.dart';

class PokemonDetailSkeleton extends StatelessWidget {
  const PokemonDetailSkeleton({super.key});

  static const Key headerKey = Key('pokemon_detail_skeleton_header');

  static Key sectionKey(int index) =>
      ValueKey<String>('pokemon_detail_skeleton_section_$index');

  @override
  Widget build(BuildContext context) {
    final base = SkeletonShimmerColors.base(context);
    final highlight = SkeletonShimmerColors.highlight(context);
    const headerHeight = PokemonSpriteLayoutSizes.detailHeaderHeight;
    const circleSize = PokemonSpriteLayoutSizes.detailHeaderCircleDiameter;
    final circleTop = PokemonSpriteLayoutSizes.detailHeaderCircleTop(
      headerHeight,
    );

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        children: [
          SizedBox(
            key: headerKey,
            height: headerHeight,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final circleLeft = (constraints.maxWidth - circleSize) / 2;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: circleTop,
                      left: circleLeft,
                      width: circleSize,
                      height: circleSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: base,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: _ActionStub(),
                    ),
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: _ActionStub(),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 44, 16, 8),
                    child: _SurfaceCardStub(
                      color: base,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bone(width: 160, height: 22, color: base),
                          const SizedBox(height: 8),
                          _Bone(width: 56, height: 14, color: base),
                          const SizedBox(height: 12),
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
                  const SizedBox(height: 8),
                  _SectionBlock(
                    index: 0,
                    color: base,
                    bodyHeight: 48,
                  ),
                  const SizedBox(height: 24),
                  _SectionBlock(
                    index: 1,
                    color: base,
                    bodyHeight: 28,
                  ),
                  const SizedBox(height: 24),
                  _SectionBlock(
                    index: 2,
                    color: base,
                    bodyHeight: 72,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionStub extends StatelessWidget {
  const _ActionStub();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: SkeletonShimmerColors.base(context),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.index,
    required this.color,
    required this.bodyHeight,
  });

  final int index;
  final Color color;
  final double bodyHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: PokemonDetailSkeleton.sectionKey(index),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _SurfaceCardStub(
        color: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Bone(width: 100, height: 16, color: color),
            const SizedBox(height: 12),
            _Bone(height: bodyHeight, color: color),
          ],
        ),
      ),
    );
  }
}

/// Silhouette of DetailSurfaceCard: radius 16, padding 16.
class _SurfaceCardStub extends StatelessWidget {
  const _SurfaceCardStub({
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.height,
    required this.color,
    this.width,
    this.radius = 4,
  });

  final double? width;
  final double height;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
