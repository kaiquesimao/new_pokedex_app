import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/type_weakness_utils.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';

class PokemonWeaknessSection extends StatelessWidget {
  const PokemonWeaknessSection({required this.types, super.key});

  final List<PokemonType> types;

  @override
  Widget build(BuildContext context) {
    final weaknesses = weaknessesForTypes(types).toList()
      ..sort((a, b) => a.labelPt.compareTo(b.labelPt));

    if (weaknesses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fraquezas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weaknesses
                .map((type) => PokemonTypeChip(type: type))
                .toList(),
          ),
        ],
      ),
    );
  }
}
