import 'package:flutter/material.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/presentation/utils/pokemon_detail_formatters.dart';

class PokemonDetailAboutSection extends StatelessWidget {
  const PokemonDetailAboutSection({required this.pokemon, super.key});

  final PokemonDetail pokemon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryAbility = pokemon.abilities.isNotEmpty
        ? pokemon.abilities.firstWhere(
            (a) => !a.isHidden,
            orElse: () => pokemon.abilities.first,
          )
        : null;
    final category = pokemon.eggGroups.isNotEmpty
        ? PokemonDetailFormatters.eggGroupsLabel(
            [pokemon.eggGroups.first],
          )
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pokemon.flavorText != null) ...[
            Text(
              pokemon.flavorText!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
          ],
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.4,
            children: [
              _InfoTile(
                label: 'Peso',
                value: '${pokemon.weightKg.toStringAsFixed(1)} kg',
              ),
              _InfoTile(
                label: 'Altura',
                value: '${pokemon.heightMeters.toStringAsFixed(1)} m',
              ),
              _InfoTile(label: 'Categoria', value: category),
              _InfoTile(
                label: 'Habilidade',
                value: primaryAbility == null
                    ? '—'
                    : PokemonDetailFormatters.abilityLabel(
                        primaryAbility.name,
                        isHidden: primaryAbility.isHidden,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _GenderBar(genderRate: pokemon.genderRate),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _GenderBar extends StatelessWidget {
  const _GenderBar({required this.genderRate});

  final int genderRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (genderRate < 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gênero',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sem gênero',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }

    final femalePercent = genderRate / 255 * 100;
    final malePercent = 100 - femalePercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gênero',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                if (malePercent > 0)
                  Expanded(
                    flex: malePercent.round().clamp(1, 100),
                    child: const ColoredBox(color: Color(0xFF4A90D9)),
                  ),
                if (femalePercent > 0)
                  Expanded(
                    flex: femalePercent.round().clamp(1, 100),
                    child: const ColoredBox(color: Color(0xFFE85D8A)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              '♂ ${malePercent.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF4A90D9),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '♀ ${femalePercent.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFFE85D8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
