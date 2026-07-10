import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/constants/region_card_assets.dart';
import 'package:pokedex_app/core/locale/pokemon_filters_l10n.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';
import 'package:riverpod/misc.dart';

class RegionGenerationCard extends StatelessWidget {
  const RegionGenerationCard({required this.data, super.key, this.onTap});

  final RegionCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                              l10n.regionGenerationBadgeLabel(
                                data.generationNumber,
                              ),
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

class _StarterSprites extends ConsumerWidget {
  const _StarterSprites({required this.starterIds});

  final List<int> starterIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final id in starterIds)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: _StarterSprite(pokemonId: id),
          ),
      ],
    );
  }
}

class _StarterSprite extends ConsumerWidget {
  const _StarterSprite({required this.pokemonId});

  final int pokemonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spriteUrl = ref
        .watch(pokemonSpriteUrlProvider(pokemonId))
        .value;

    if (spriteUrl == null) {
      return const SizedBox(
        width: PokemonSpriteDisplaySizes.regionStarter,
        height: PokemonSpriteDisplaySizes.regionStarter,
        child: PokemonSpriteLoadingPlaceholder(
          width: PokemonSpriteDisplaySizes.regionStarter,
          height: PokemonSpriteDisplaySizes.regionStarter,
        ),
      );
    }

    return PokemonSpriteImage(
      imageUrl: spriteUrl,
      width: PokemonSpriteDisplaySizes.regionStarter,
      height: PokemonSpriteDisplaySizes.regionStarter,
      maxCachePixels: PokemonSpriteCachePresets.compact,
      errorIconSize: 36,
    );
  }
}

final FutureProviderFamily<String?, int> pokemonSpriteUrlProvider =
    FutureProvider.family<String?, int>((
      ref,
      pokemonId,
    ) async {
      try {
        final summary = await ref
            .read(pokemonRepositoryProvider)
            .getSummaryById(pokemonId);
        return summary.spriteUrl;
      } on Object {
        return null;
      }
    });
