import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PokemonGridTileSkeleton extends StatelessWidget {
  const PokemonGridTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
