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
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: [
              _InfoTile(
                icon: Icons.monitor_weight_outlined,
                label: 'Peso',
                value:
                    '${PokemonDetailFormatters.decimal(pokemon.weightKg)} kg',
              ),
              _InfoTile(
                icon: Icons.height,
                label: 'Altura',
                value:
                    '${PokemonDetailFormatters.decimal(pokemon.heightMeters)} m',
              ),
              _InfoTile(
                icon: Icons.grid_view_rounded,
                label: 'Categoria',
                value: category,
              ),
              _InfoTile(
                icon: Icons.catching_pokemon,
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
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: labelColor),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _GenderBar extends StatelessWidget {
  const _GenderBar({required this.genderRate});

  final int genderRate;

  static const _maleColor = Color(0xFF4A90D9);
  static const _femaleColor = Color(0xFFE85D8A);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: labelColor,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    );

    if (genderRate < 0) {
      return Column(
        children: [
          Text('GÊNERO', style: labelStyle),
          const SizedBox(height: 8),
          Text(
            'Sem gênero',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final femalePercent = genderRate / 255 * 100;
    final malePercent = 100 - femalePercent;

    return Column(
      children: [
        Text('GÊNERO', style: labelStyle),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (malePercent > 0)
                  Expanded(
                    flex: malePercent.round().clamp(1, 100),
                    child: const ColoredBox(color: _maleColor),
                  ),
                if (femalePercent > 0)
                  Expanded(
                    flex: femalePercent.round().clamp(1, 100),
                    child: const ColoredBox(color: _femaleColor),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              '♂ ${PokemonDetailFormatters.decimal(malePercent)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _maleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '♀ ${PokemonDetailFormatters.decimal(femalePercent)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _femaleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
