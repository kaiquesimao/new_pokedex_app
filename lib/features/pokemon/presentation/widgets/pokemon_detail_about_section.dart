import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/core/locale/poke_api_localized_text.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/localized_ability_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/localized_category_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/localized_flavor_text_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/utils/pokemon_detail_formatters.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/detail_surface_card.dart';

class PokemonDetailAboutSection extends ConsumerWidget {
  const PokemonDetailAboutSection({
    required this.pokemon,
    this.flavorTextEntries = const [],
    super.key,
  });

  final PokemonDetail pokemon;
  final List<dynamic> flavorTextEntries;

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
    final targetLang = locale.pokeApiCode;
    final generaEntries = pokemon.generaEntries;
    final flavorAsync = ref.watch(
      localizedFlavorTextProvider((
        flavorEntries: flavorTextEntries,
        targetLang: targetLang,
      )),
    );
    final categoryAsync = ref.watch(
      localizedCategoryProvider((
        generaEntries: generaEntries,
        targetLang: targetLang,
      )),
    );
    final abilityAsync = primaryAbility == null
        ? null
        : ref.watch(
            localizedAbilityProvider((
              slug: primaryAbility.slug,
              targetLang: targetLang,
            )),
          );
    final needsFlavorMt = _mayNeedMachineTranslation(
      flavorTextEntries,
      targetLang,
      'flavor_text',
    );
    final needsCategoryMt = _mayNeedMachineTranslation(
      generaEntries,
      targetLang,
      'genus',
    );
    final descriptionStyle = DetailSurfaceCard.bodyStyle(context);
    final description = flavorAsync.when<Widget?>(
      loading: () {
        if (needsFlavorMt) {
          return _loadingIndicator(theme, l10n.flavorTextTranslating);
        }
        final text =
            PokeApiLocalizedText.pickFlavorText(
              flavorTextEntries,
              targetLang,
            ) ??
            pokemon.flavorText ??
            '';
        if (text.isEmpty) return null;
        return Text(text, style: descriptionStyle);
      },
      data: (resolved) {
        final text = resolved?.text ?? pokemon.flavorText ?? '';
        if (text.isEmpty) return null;
        return Text(text, style: descriptionStyle);
      },
      error: (_, _) {
        final text = pokemon.flavorText ?? '';
        if (text.isEmpty) return null;
        return Text(text, style: descriptionStyle);
      },
    );
    final categoryValue = categoryAsync.when(
      loading: () {
        if (needsCategoryMt) {
          return _loadingIndicator(theme, l10n.flavorTextTranslating);
        }
        return _tileText(
          _syncCategoryText(generaEntries, targetLang, pokemon.category),
          descriptionStyle,
        );
      },
      data: (resolved) => _tileText(
        resolved?.text ?? pokemon.category ?? '—',
        descriptionStyle,
      ),
      error: (_, _) => _tileText(
        _syncCategoryText(generaEntries, targetLang, pokemon.category),
        descriptionStyle,
      ),
    );
    final abilityValue = primaryAbility == null
        ? _tileText('—', descriptionStyle)
        : abilityAsync!.when(
            loading: () => _loadingIndicator(theme, l10n.flavorTextTranslating),
            data: (resolved) => _tileText(
              primaryAbility.isHidden
                  ? '${resolved.text}${l10n.abilityHiddenSuffix}'
                  : resolved.text,
              descriptionStyle,
            ),
            error: (_, _) => _tileText(
              primaryAbility.isHidden
                  ? '${_capitalize(primaryAbility.slug)}'
                        '${l10n.abilityHiddenSuffix}'
                  : _capitalize(primaryAbility.slug),
              descriptionStyle,
            ),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (description != null) ...[
            DetailSurfaceCard(child: description),
            const SizedBox(height: 20),
          ],
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            mainAxisExtent: 104,
            children: [
              _InfoTile(
                icon: Icons.monitor_weight_outlined,
                label: l10n.detailWeight,
                value: _tileText(
                  '${PokemonDetailFormatters.decimal(pokemon.weightKg, locale)} kg',
                  descriptionStyle,
                ),
              ),
              _InfoTile(
                icon: Icons.height,
                label: l10n.detailHeight,
                value: _tileText(
                  '${PokemonDetailFormatters.decimal(pokemon.heightMeters, locale)} m',
                  descriptionStyle,
                ),
              ),
              _InfoTile(
                icon: Icons.grid_view_rounded,
                label: l10n.detailCategory,
                value: categoryValue,
                wrapValue: true,
              ),
              _InfoTile(
                icon: Icons.catching_pokemon,
                label: l10n.detailAbility,
                value: abilityValue,
                wrapValue: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          DetailSurfaceCard(
            child: _GenderBar(
              genderRate: pokemon.genderRate,
              l10n: l10n,
              locale: locale,
            ),
          ),
        ],
      ),
    );
  }
}

bool _mayNeedMachineTranslation(
  List<dynamic> entries,
  String targetLang,
  String textKey,
) {
  if (targetLang == 'en' || entries.isEmpty) return false;
  if (PokeApiLocalizedText.hasEntry(entries, targetLang, textKey)) {
    return false;
  }
  return PokeApiLocalizedText.pickEnglish(entries, textKey) != null;
}

String _syncCategoryText(
  List<dynamic> generaEntries,
  String targetLang,
  String? fallback,
) {
  if (generaEntries.isEmpty) return fallback ?? '—';
  return PokeApiLocalizedText.pickOfficial(
        generaEntries,
        targetLang,
        'genus',
      ) ??
      PokeApiLocalizedText.pickEnglish(generaEntries, 'genus') ??
      fallback ??
      '—';
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

Widget _tileText(String text, TextStyle? style) {
  return Text(
    text,
    style: style,
    textAlign: TextAlign.center,
  );
}

Widget _loadingIndicator(ThemeData theme, String semanticsLabel) {
  return Semantics(
    label: semanticsLabel,
    child: Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
      ),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.wrapValue = false,
  });

  final IconData icon;
  final String label;
  final Widget value;
  final bool wrapValue;

  @override
  Widget build(BuildContext context) {
    final titleStyle = DetailSurfaceCard.titleStyle(context);
    final bodyStyle = DetailSurfaceCard.bodyStyle(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: titleStyle?.color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DetailSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: wrapValue
              ? value
              : DefaultTextStyle(
                  style: bodyStyle ?? Theme.of(context).textTheme.bodyLarge!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  child: value,
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
    final titleStyle = DetailSurfaceCard.titleStyle(context);

    if (genderRate < 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.detailGender, style: titleStyle),
          const SizedBox(height: 8),
          Text(
            l10n.genderNone,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }

    final femalePercent = PokemonDetailFormatters.femalePercent(genderRate);
    final malePercent = PokemonDetailFormatters.malePercent(genderRate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.detailGender, style: titleStyle),
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
