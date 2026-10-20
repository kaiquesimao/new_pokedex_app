import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/pokemon_hero_tags.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/core/utils/pokemon_formatters.dart';
import 'package:pokedex_app/shared/widgets/detail_surface_card.dart';
import 'package:pokedex_app/shared/widgets/pokemon_primary_type_backdrop.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';

class PokemonDetailHeader extends StatelessWidget {
  const new({
    required this.headerColor,
    required this.isFavorite,
    required this.onBack,
    required this.onFavoriteTap,
    required this.sprite,
    this.primaryType,
    super.key,
  });

  final PokemonType? primaryType;
  final Color headerColor;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavoriteTap;
  final Widget sprite;

  @override
  Widget build(BuildContext context) {
    final headerActionColor = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const headerHeight = PokemonSpriteLayoutSizes.detailHeaderHeight;
    const circleSize = PokemonSpriteLayoutSizes.detailHeaderCircleDiameter;
    final typeIconSize = PokemonSpriteLayoutSizes.detailTypeIconSize(
      circleSize,
    );
    final circleTop = PokemonSpriteLayoutSizes.detailHeaderCircleTop(
      headerHeight,
    );
    final circleGradientColors = isDark
        ? [
            headerColor.withValues(alpha: 0.55),
            headerColor.withValues(alpha: 0.18),
          ]
        : [headerColor, Color.lerp(headerColor, Colors.white, 0.28)!];

    return LayoutBuilder(
      builder: (context, constraints) {
        final circleLeft = (constraints.maxWidth - circleSize) / 2;

        return SizedBox(
          height: headerHeight,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: circleTop,
                left: circleLeft,
                width: circleSize,
                height: circleSize,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: circleGradientColors,
                        ),
                      ),
                    ),
                    if (primaryType != null)
                      PokemonPrimaryTypeBackdrop(
                        type: primaryType!,
                        size: typeIconSize,
                        opacity: isDark
                            ? PokemonPrimaryTypeBackdrop.detailOpacity
                            : PokemonPrimaryTypeBackdrop.detailLightOpacity,
                      ),
                    sprite,
                  ],
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    sizeVariant: ButtonSizeVariant.medium,
                    shapeVariant: ButtonShapeVariant.round,
                  ),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: headerActionColor,
                  ),
                  onPressed: onBack,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    sizeVariant: ButtonSizeVariant.medium,
                    shapeVariant: ButtonShapeVariant.round,
                  ),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : headerActionColor,
                    size: 28,
                  ),
                  onPressed: onFavoriteTap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PokemonDetailIdentityCard extends StatelessWidget {
  const new({
    required this.displayName,
    required this.pokemonId,
    required this.types,
    super.key,
  });

  final String displayName;
  final int pokemonId;
  final List<PokemonType> types;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 44, 16, 8),
      child: DetailSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              PokemonFormatters.displayNumber(pokemonId),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (types.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: types
                    .map((type) => PokemonTypeChip(type: type))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Landing sprite for a detail opened before the bundle exists.
class PokemonDetailPreviewSprite extends StatelessWidget {
  const new({required this.pokemonId, this.spriteUrl, super.key});

  final int pokemonId;
  final String? spriteUrl;

  @override
  Widget build(BuildContext context) {
    final url = spriteUrl;
    if (url == null || url.isEmpty) {
      return Hero(
        tag: PokemonHeroTags.sprite(pokemonId),
        child: const Material(
          color: Colors.transparent,
          child: Icon(Icons.catching_pokemon, size: 96, color: Colors.white),
        ),
      );
    }

    return PokemonSpriteImage(
      imageUrl: url,
      height: PokemonSpriteDisplaySizes.detail,
      maxCachePixels: PokemonSpriteCachePresets.detail,
      heroTag: PokemonHeroTags.sprite(pokemonId),
      errorIconColor: Colors.white,
      errorIconSize: 96,
    );
  }
}
