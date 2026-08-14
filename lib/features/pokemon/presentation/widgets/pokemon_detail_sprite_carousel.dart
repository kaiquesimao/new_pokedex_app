import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/pokemon_hero_tags.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_sprite_variant.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_sprite_variant_labels.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_cry_player_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_detail_sprite_variants_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/utils/pokemon_sprite_variant_label_localizer.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';

/// Horizontal form/shiny carousel for the detail hero sprite.
class const PokemonDetailSpriteCarousel({
  required final int routePokemonId,
  required final List<PokemonSpriteVariant> variants,
  final String? fallbackCryUrl,
  final String? fallbackLegacyCryUrl,
  super.key,
}) extends ConsumerStatefulWidget {
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
    _tapController.forward(from: 0);
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
            _SpriteVariantLabelChip(label: formLabel),
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
class const PokemonDetailTappableSprite({
  required final int pokemonId,
  required final String imageUrl,
  final String? cryUrl,
  final String? legacyCryUrl,
  super.key,
}) extends ConsumerStatefulWidget {
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
    _tapController.forward(from: 0);
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

/// Hero sprite that shows a mini loader while extra forms are fetched.
class const PokemonDetailHeroSprite({
  required final int pokemonId,
  required final PokemonDetail pokemon,
  super.key,
}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variantsAsync = ref.watch(
      pokemonDetailSpriteVariantsProvider(pokemonId),
    );

    return variantsAsync.when(
      data: (variants) {
        if (variants.length > 1) {
          return PokemonDetailSpriteCarousel(
            routePokemonId: pokemonId,
            variants: variants,
            fallbackCryUrl: pokemon.cryUrl,
            fallbackLegacyCryUrl: pokemon.legacyCryUrl,
          );
        }
        if (variants.length == 1) {
          return PokemonDetailTappableSprite(
            pokemonId: pokemonId,
            imageUrl: variants.first.imageUrl,
            cryUrl: pokemon.cryUrl,
            legacyCryUrl: pokemon.legacyCryUrl,
          );
        }
        return _fallbackSprite();
      },
      loading: () {
        final l10n = AppLocalizations.of(context);
        final formLabel = PokemonSpriteVariantLabelLocalizer.label(
          l10n,
          PokemonSpriteVariantLabels.keyForApiName(pokemon.name),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _fallbackSprite(),
            const SizedBox(height: 8),
            PokemonDetailFormsLoadingIndicator(formLabel: formLabel),
          ],
        );
      },
      error: (_, _) => _fallbackSprite(),
    );
  }

  Widget _fallbackSprite() {
    if (pokemon.spriteUrl != null) {
      return PokemonDetailTappableSprite(
        pokemonId: pokemonId,
        imageUrl: pokemon.spriteUrl!,
        cryUrl: pokemon.cryUrl,
        legacyCryUrl: pokemon.legacyCryUrl,
      );
    }
    return Hero(
      tag: PokemonHeroTags.sprite(pokemonId),
      child: const Material(
        color: Colors.transparent,
        child: Icon(
          Icons.catching_pokemon,
          size: 96,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Mini loader in the form-label slot while variants are still loading.
class const PokemonDetailFormsLoadingIndicator({
  final String? formLabel,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = formLabel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          _SpriteVariantLabelChip(label: label),
          const SizedBox(height: 6),
        ],
        Semantics(
          label: l10n.pokemonFormsLoading,
          child: const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class const _SpriteVariantLabelChip({required final String label})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
