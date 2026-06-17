import 'package:flutter/material.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:shimmer/shimmer.dart';

class PokemonListRowSkeleton extends StatelessWidget {
  const PokemonListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: PokemonSpriteLayoutSizes.listRowHeight,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
