import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/constants/pokemon_hero_tags.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_sprite_variant.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_cry_player_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/utils/pokemon_sprite_variant_label_localizer.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';

/// Horizontal form/shiny carousel for the detail hero sprite.
class PokemonDetailSpriteCarousel extends ConsumerStatefulWidget {
  const PokemonDetailSpriteCarousel({
    required this.routePokemonId,
    required this.variants,
    this.fallbackCryUrl,
    this.fallbackLegacyCryUrl,
    super.key,
  });

  final int routePokemonId;
  final List<PokemonSpriteVariant> variants;
  final String? fallbackCryUrl;
  final String? fallbackLegacyCryUrl;

  @override
  ConsumerState<PokemonDetailSpriteCarousel> createState() =>
      _PokemonDetailSpriteCarouselState();
}

class _PokemonDetailSpriteCarouselState
    extends ConsumerState<PokemonDetailSpriteCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _tapController;
  late final Animation<double> _tapScale;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _tapScale = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(begin: 1, end: 0.92),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.92, end: 1),
          weight: 50,
        ),
      ],
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  PokemonSpriteVariant get _current => widget.variants[_pageIndex];

  Future<void> _onTap() async {
    unawaited(_tapController.forward(from: 0));
    final variant = _current;
    final useRouteCry = variant.pokemonId == widget.routePokemonId;
    await ref
        .read(pokemonCryPlayerProvider.notifier)
        .playCry(
          cryUrl: useRouteCry ? widget.fallbackCryUrl : null,
          legacyCryUrl: useRouteCry ? widget.fallbackLegacyCryUrl : null,
          pokemonId: variant.pokemonId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showControls = widget.variants.length > 1;
    final formLabel = PokemonSpriteVariantLabelLocalizer.label(
      l10n,
      _current.labelKey,
    );

    return Semantics(
      label: showControls
          ? l10n.pokemonFormCarouselSemantics(formLabel)
          : l10n.pokemonCryPlaySemantics,
      button: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: PokemonSpriteDisplaySizes.detail,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.variants.length,
              onPageChanged: (index) => setState(() => _pageIndex = index),
              itemBuilder: (context, index) {
                final variant = widget.variants[index];
                final heroTag =
                    !variant.isShiny &&
                        variant.pokemonId == widget.routePokemonId
                    ? PokemonHeroTags.sprite(widget.routePokemonId)
                    : null;

                return GestureDetector(
                  onTap: _onTap,
                  behavior: HitTestBehavior.opaque,
                  child: ScaleTransition(
                    scale: _tapScale,
                    child: PokemonSpriteImage(
                      imageUrl: variant.imageUrl,
                      height: PokemonSpriteDisplaySizes.detail,
                      maxCachePixels: PokemonSpriteCachePresets.detail,
                      heroTag: heroTag,
                      errorIconColor: Colors.white,
                      errorIconSize: 96,
                    ),
                  ),
                );
              },
            ),
          ),
          if (showControls) ...[
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Text(
                  formLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.variants.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _pageIndex ? 8 : 6,
                    height: i == _pageIndex ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _pageIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Single tappable sprite used when only one visual variant exists.
class PokemonDetailTappableSprite extends ConsumerStatefulWidget {
  const PokemonDetailTappableSprite({
    required this.pokemonId,
    required this.imageUrl,
    this.cryUrl,
    this.legacyCryUrl,
    super.key,
  });

  final int pokemonId;
  final String imageUrl;
  final String? cryUrl;
  final String? legacyCryUrl;

  @override
  ConsumerState<PokemonDetailTappableSprite> createState() =>
      _PokemonDetailTappableSpriteState();
}

class _PokemonDetailTappableSpriteState
    extends ConsumerState<PokemonDetailTappableSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapController;
  late final Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _tapScale = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(begin: 1, end: 0.92),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.92, end: 1),
          weight: 50,
        ),
      ],
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    unawaited(_tapController.forward(from: 0));
    await ref
        .read(pokemonCryPlayerProvider.notifier)
        .playCry(
          cryUrl: widget.cryUrl,
          legacyCryUrl: widget.legacyCryUrl,
          pokemonId: widget.pokemonId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: l10n.pokemonCryPlaySemantics,
      child: GestureDetector(
        onTap: _onTap,
        child: ScaleTransition(
          scale: _tapScale,
          child: PokemonSpriteImage(
            imageUrl: widget.imageUrl,
            height: PokemonSpriteDisplaySizes.detail,
            maxCachePixels: PokemonSpriteCachePresets.detail,
            heroTag: PokemonHeroTags.sprite(widget.pokemonId),
            errorIconColor: Colors.white,
            errorIconSize: 96,
          ),
        ),
      ),
    );
  }
}
