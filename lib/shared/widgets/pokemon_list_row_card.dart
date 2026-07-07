import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/pokemon_hero_tags.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/locale/pokemon_type_l10n.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/core/utils/pokemon_formatters.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/pokemon_primary_type_backdrop.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';

class PokemonListRowCard extends StatelessWidget {
  const PokemonListRowCard({
    required this.number,
    required this.name,
    required this.types,
    super.key,
    this.spriteUrl,
    this.isFavorite = false,
    this.heroShellTabIndex,
    this.useHero = false,
    this.heroPokemonId,
    this.onTap,
    this.onFavoriteTap,
  });

  final int number;
  final String name;
  final List<PokemonType> types;
  final String? spriteUrl;
  final bool isFavorite;

  /// Shell tab that must be active for the list-to-detail hero animation.
  final int? heroShellTabIndex;

  /// Enables hero on root-navigator lists (e.g. regional Pokédex).
  final bool useHero;

  /// Pokémon id used for the hero tag; defaults to [number].
  final int? heroPokemonId;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryType = types.isNotEmpty ? types.first : PokemonType.normal;
    final typeColor = PokemonTypeColors.forType(primaryType, isDark: isDark);

    final l10n = AppLocalizations.of(context);
    final typeLabels = types.map((t) => t.label(l10n)).join(', ');
    final semanticsLabel =
        '$name, ${PokemonFormatters.displayNumber(number)}'
        '${typeLabels.isEmpty ? '' : ', $typeLabels'}';

    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              height: PokemonSpriteLayoutSizes.listRowHeight,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            PokemonFormatters.displayNumber(number),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: types
                                .map((type) => PokemonTypeChip(type: type))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _TypePanel(
                    typeColor: typeColor,
                    primaryType: primaryType,
                    number: number,
                    spriteUrl: spriteUrl,
                    isFavorite: isFavorite,
                    heroShellTabIndex: heroShellTabIndex,
                    useHero: useHero,
                    heroPokemonId: heroPokemonId,
                    onFavoriteTap: onFavoriteTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypePanel extends StatelessWidget {
  const _TypePanel({
    required this.typeColor,
    required this.primaryType,
    required this.number,
    this.spriteUrl,
    this.isFavorite = false,
    this.heroShellTabIndex,
    this.useHero = false,
    this.heroPokemonId,
    this.onFavoriteTap,
  });

  final Color typeColor;
  final PokemonType primaryType;
  final int number;
  final String? spriteUrl;
  final bool isFavorite;
  final int? heroShellTabIndex;
  final bool useHero;
  final int? heroPokemonId;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
      child: SizedBox(
        width: PokemonSpriteLayoutSizes.listRowPanelWidth,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: typeColor),
            Center(child: PokemonPrimaryTypeBackdrop(type: primaryType)),
            Center(
              child: spriteUrl != null
                  ? PokemonSpriteImage(
                      imageUrl: spriteUrl!,
                      height: PokemonSpriteDisplaySizes.listRow,
                      maxCachePixels: PokemonSpriteCachePresets.listRow,
                      heroTag: PokemonHeroTags.listSpriteHeroTag(
                        context,
                        pokemonId: heroPokemonId ?? number,
                        heroShellTabIndex: heroShellTabIndex,
                        useHero: useHero,
                      ),
                      errorIconColor: Colors.white70,
                    )
                  : const Icon(
                      Icons.catching_pokemon,
                      size: 56,
                      color: Colors.white70,
                    ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Semantics(
                label: isFavorite
                    ? l10n.favoriteRemoveSemantics
                    : l10n.favoriteAddSemantics,
                button: true,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                    size: 20,
                  ),
                  onPressed: onFavoriteTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
