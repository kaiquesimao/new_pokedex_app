import 'package:flutter/material.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_skeleton.dart';

class PokemonListSkeleton extends StatelessWidget {
  const PokemonListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const PokemonListRowSkeleton(),
    );
  }
}
