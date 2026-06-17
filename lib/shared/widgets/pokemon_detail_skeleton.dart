import 'package:flutter/material.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:shimmer/shimmer.dart';

class PokemonDetailSkeleton extends StatelessWidget {
  const PokemonDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        children: [
          Container(
            height: PokemonSpriteLayoutSizes.detailHeaderHeight,
            width: double.infinity,
            color: base,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: List.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
