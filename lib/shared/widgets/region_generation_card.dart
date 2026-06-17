import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/region_card_assets.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';

class RegionGenerationCard extends StatelessWidget {
  const RegionGenerationCard({required this.data, super.key, this.onTap});

  final RegionCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [data.gradientStart, data.gradientEnd],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (data.landscapeAsset != null)
                  Image.asset(
                    data.landscapeAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.generationLabel(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StarterSprites(starterIds: data.starterIds),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarterSprites extends StatelessWidget {
  const _StarterSprites({required this.starterIds});

  final List<int> starterIds;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final id in starterIds)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: PokemonSpriteImage(
              imageUrl: RegionCardAssets.starterSpriteUrl(id),
              width: PokemonSpriteDisplaySizes.regionStarter,
              height: PokemonSpriteDisplaySizes.regionStarter,
              maxCachePixels: PokemonSpriteCachePresets.compact,
              errorIconSize: 36,
            ),
          ),
      ],
    );
  }
}
