import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/presentation/utils/pokemon_detail_formatters.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

class PokemonDetailAboutSection extends ConsumerWidget {
  const PokemonDetailAboutSection({required this.pokemon, super.key});

  final PokemonDetail pokemon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(appLocaleProvider);
    final primaryAbility = pokemon.abilities.isNotEmpty
        ? pokemon.abilities.firstWhere(
            (a) => !a.isHidden,
            orElse: () => pokemon.abilities.first,
          )
        : null;
    final l10n = AppLocalizations.of(context);
    final category = pokemon.eggGroups.isNotEmpty
        ? pokemon.eggGroups.first
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                label: l10n.detailWeight,
                value:
                    '${PokemonDetailFormatters.decimal(pokemon.weightKg, locale)} kg',
              ),
              _InfoTile(
                icon: Icons.height,
                label: l10n.detailHeight,
                value:
                    '${PokemonDetailFormatters.decimal(pokemon.heightMeters, locale)} m',
              ),
              _InfoTile(
                icon: Icons.grid_view_rounded,
                label: l10n.detailCategory,
                value: category,
              ),
              _InfoTile(
                icon: Icons.catching_pokemon,
                label: l10n.detailAbility,
                value: primaryAbility == null
                    ? '—'
                    : primaryAbility.isHidden
                    ? '${primaryAbility.name}${l10n.abilityHiddenSuffix}'
                    : primaryAbility.name,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _GenderBar(
            genderRate: pokemon.genderRate,
            l10n: l10n,
            locale: locale,
          ),
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
  const _GenderBar({
    required this.genderRate,
    required this.l10n,
    required this.locale,
  });

  final int genderRate;
  final AppLocalizations l10n;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maleColor = theme.colorScheme.primary;
    const femaleColor = AppColorsLight.genderFemale;
    final labelColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: labelColor,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    );

    if (genderRate < 0) {
      return Column(
        children: [
          Text(l10n.detailGender.toUpperCase(), style: labelStyle),
          const SizedBox(height: 8),
          Text(
            l10n.genderNone,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final femalePercent = PokemonDetailFormatters.femalePercent(genderRate);
    final malePercent = PokemonDetailFormatters.malePercent(genderRate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.detailGender.toUpperCase(),
          style: labelStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        _GenderBarTrack(
          malePercent: malePercent,
          femalePercent: femalePercent,
          maleColor: maleColor,
          femaleColor: femaleColor,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              '♂ ${PokemonDetailFormatters.decimal(malePercent, locale)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: maleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '♀ ${PokemonDetailFormatters.decimal(femalePercent, locale)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: femaleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderBarTrack extends StatelessWidget {
  const _GenderBarTrack({
    required this.malePercent,
    required this.femalePercent,
    required this.maleColor,
    required this.femaleColor,
  });

  final double malePercent;
  final double femalePercent;
  final Color maleColor;
  final Color femaleColor;
  static const _height = 12.0;

  @override
  Widget build(BuildContext context) {
    final maleFraction = (malePercent / 100).clamp(0.0, 1.0);

    final BoxDecoration decoration;
    if (maleFraction <= 0) {
      decoration = BoxDecoration(
        color: femaleColor,
        borderRadius: BorderRadius.circular(999),
      );
    } else if (maleFraction >= 1) {
      decoration = BoxDecoration(
        color: maleColor,
        borderRadius: BorderRadius.circular(999),
      );
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [maleColor, maleColor, femaleColor, femaleColor],
          stops: [0, maleFraction, maleFraction, 1],
        ),
      );
    }

    return Container(
      key: const Key('gender_bar_track'),
      height: _height,
      width: double.infinity,
      decoration: decoration,
    );
  }
}
