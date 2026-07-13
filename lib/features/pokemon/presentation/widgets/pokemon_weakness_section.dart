import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/locale/pokemon_type_l10n.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/type_weakness_utils.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/detail_surface_card.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';

class PokemonWeaknessSection extends StatelessWidget {
  const PokemonWeaknessSection({required this.types, super.key});

  final List<PokemonType> types;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weaknesses = weaknessesForTypes(types).toList()
      ..sort((a, b) => a.label(l10n).compareTo(b.label(l10n)));

    if (weaknesses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DetailSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pokemonDetailWeaknesses,
              style: DetailSurfaceCard.titleStyle(context),
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
      ),
    );
  }
}
