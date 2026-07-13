import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/analytics/app_analytics.dart';
import 'package:pokedex_app/core/constants/pokemon_hero_tags.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/network/network_errors.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/core/utils/pokemon_formatters.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/login_required_bottom_sheet.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_cry_player_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_detail_bundle_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_detail_sprite_variants_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/utils/pokemon_detail_formatters.dart';
import 'package:pokedex_app/features/pokemon/presentation/widgets/pokemon_detail_about_section.dart';
import 'package:pokedex_app/features/pokemon/presentation/widgets/pokemon_detail_sprite_carousel.dart';
import 'package:pokedex_app/features/pokemon/presentation/widgets/pokemon_weakness_section.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/evolution_chain_node.dart';
import 'package:pokedex_app/shared/widgets/offline_banner.dart';
import 'package:pokedex_app/shared/widgets/pokemon_detail_skeleton.dart';
import 'package:pokedex_app/shared/widgets/pokemon_primary_type_backdrop.dart';
import 'package:pokedex_app/shared/widgets/pokemon_stat_bar.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';
import 'package:pokedex_app/shared/widgets/responsive_content_frame.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';
import 'package:pokedex_app/shared/widgets/wide_viewport_backdrop.dart';

class PokemonDetailPage extends ConsumerWidget {
  const PokemonDetailPage({required this.pokemonId, super.key});

  final int pokemonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<bool>>(connectivityStatusProvider, (previous, next) {
      if (next.value != true) return;

      final current = ref.read(pokemonDetailBundleProvider(pokemonId));
      if (!shouldReloadPokemonDetailOnConnectivityRestore(current)) return;

      unawaited(() async {
        await ref.read(connectivityServiceProvider).refresh();
        ref.invalidate(pokemonDetailBundleProvider(pokemonId));
      }());
    });

    final bundleAsync = ref.watch(pokemonDetailBundleProvider(pokemonId));

    return bundleAsync.when(
      loading: () => Scaffold(
        backgroundColor: wideViewportAwareScaffoldColor(context),
        body: const SafePageBody(
          child: ResponsiveContentFrame(
            expandHeight: true,
            child: PokemonDetailSkeleton(),
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: SafePageBody.belowAppBar(
          child: OfflineEmptyState(
            message: friendlyErrorMessage(AppLocalizations.of(context), error),
            isConnectivityFailure: isConnectivityFailure(error),
            onRetry: () =>
                ref.invalidate(pokemonDetailBundleProvider(pokemonId)),
          ),
        ),
      ),
      data: (bundle) => _PokemonDetailContent(
        pokemonId: pokemonId,
        pokemon: bundle.detail,
        evolution: bundle.evolution,
        flavorTextEntries: bundle.flavorTextEntries,
      ),
    );
  }
}

bool shouldReloadPokemonDetailOnConnectivityRestore(
  AsyncValue<PokemonDetailBundle> current,
) {
  return current.hasError
      ? isConnectivityFailure(current.error!)
      : current.hasValue && current.requireValue.isOfflineMode;
}

class _PokemonDetailContent extends ConsumerStatefulWidget {
  const _PokemonDetailContent({
    required this.pokemonId,
    required this.pokemon,
    required this.evolution,
    this.flavorTextEntries = const [],
  });

  final int pokemonId;
  final PokemonDetail pokemon;
  final EvolutionChain evolution;
  final List<dynamic> flavorTextEntries;

  @override
  ConsumerState<_PokemonDetailContent> createState() =>
      _PokemonDetailContentState();
}

class _PokemonDetailContentState extends ConsumerState<_PokemonDetailContent> {
  var _statsExpanded = true;
  PokemonCryPlayerNotifier? _cryPlayer;

  @override
  void initState() {
    super.initState();
    _cryPlayer = ref.read(pokemonCryPlayerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appAnalyticsProvider)
          .pokemonViewed(
            pokemonId: widget.pokemon.id,
            name: widget.pokemon.displayName,
          );
    });
  }

  @override
  void didUpdateWidget(covariant _PokemonDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pokemonId != widget.pokemonId) {
      unawaited(_cryPlayer?.stop());
    }
  }

  @override
  void dispose() {
    unawaited(_cryPlayer?.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(pokemonCryPlayerProvider);
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(widget.pokemonId);
    final pokemon = widget.pokemon;

    final primaryType = pokemon.types.isNotEmpty ? pokemon.types.first : null;
    final headerColor = primaryType != null
        ? PokemonTypeColors.forType(
            primaryType,
            isDark: Theme.of(context).brightness == Brightness.dark,
          )
        : Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: wideViewportAwareScaffoldColor(context),
      body: SafePageBody(
        child: ResponsiveContentFrame(
          expandHeight: true,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroSection(
                  pokemonId: widget.pokemonId,
                  pokemon: pokemon,
                  primaryType: primaryType,
                  headerColor: headerColor,
                  isFavorite: isFavorite,
                  onFavoriteTap: () => _toggleFavorite(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pokemon.displayName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        PokemonFormatters.displayNumber(pokemon.id),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: pokemon.types
                            .map((t) => PokemonTypeChip(type: t))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: PokemonDetailAboutSection(
                  pokemon: pokemon,
                  flavorTextEntries: widget.flavorTextEntries,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: PokemonWeaknessSection(types: pokemon.types),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: _EvolutionSection(
                  pokemonId: widget.pokemonId,
                  evolution: widget.evolution,
                ),
              ),
              SliverToBoxAdapter(
                child: _CollapsibleStats(
                  pokemon: pokemon,
                  expanded: _statsExpanded,
                  onToggle: () =>
                      setState(() => _statsExpanded = !_statsExpanded),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFavorite(BuildContext context) {
    if (!ref.read(authProvider).isAuthenticated) {
      unawaited(showLoginRequiredBottomSheet(context));
      return;
    }

    final willFavorite = !ref
        .read(favoritesProvider)
        .contains(widget.pokemonId);
    unawaited(ref.read(favoritesProvider.notifier).toggle(widget.pokemonId));
    ref
        .read(appAnalyticsProvider)
        .favoriteToggled(pokemonId: widget.pokemonId, isFavorite: willFavorite);
  }
}

class _HeroSection extends ConsumerWidget {
  const _HeroSection({
    required this.pokemonId,
    required this.pokemon,
    required this.primaryType,
    required this.headerColor,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final int pokemonId;
  final PokemonDetail pokemon;
  final PokemonType? primaryType;
  final Color headerColor;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface;
    final headerActionColor = colorScheme.onSurface;
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
        : [
            headerColor,
            Color.lerp(headerColor, Colors.white, 0.28)!,
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final circleLeft = (constraints.maxWidth - circleSize) / 2;

        return SizedBox(
          height: headerHeight,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              ColoredBox(color: surfaceColor),
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
                    _HeroSprite(
                      pokemonId: pokemonId,
                      pokemon: pokemon,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: headerActionColor,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
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

class _HeroSprite extends ConsumerWidget {
  const _HeroSprite({
    required this.pokemonId,
    required this.pokemon,
  });

  final int pokemonId;
  final PokemonDetail pokemon;

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
      loading: _fallbackSprite,
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

class _EvolutionSection extends StatelessWidget {
  const _EvolutionSection({required this.pokemonId, required this.evolution});

  final int pokemonId;
  final EvolutionChain evolution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? theme.dividerColor
        : AppColorsLight.textSecondary.withValues(alpha: 0.25);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pokemonDetailEvolutions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: evolution.isSingleStage
                ? Column(
                    children: [
                      EvolutionChainNodeCard(
                        node: evolution.root,
                        isCurrent: true,
                        isFinalStage: true,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.pokemonDetailNoEvolution,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  )
                : EvolutionChainTree(
                    root: evolution.root,
                    currentSpeciesId: evolution.currentSpeciesId,
                    embedded: true,
                    onNodeTap: (targetPokemonId) {
                      if (targetPokemonId == pokemonId) return;
                      unawaited(context.push('/pokemon/$targetPokemonId'));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CollapsibleStats extends StatelessWidget {
  const _CollapsibleStats({
    required this.pokemon,
    required this.expanded,
    required this.onToggle,
  });

  final PokemonDetail pokemon;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    const maxStat = 255;
    final l10n = AppLocalizations.of(context);
    final total = pokemon.stats.fold<int>(0, (sum, s) => sum + s.baseStat);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Text(
                    l10n.pokemonDetailStats,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 8),
            ...pokemon.stats.map(
              (stat) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PokemonStatBar(
                  label: PokemonDetailFormatters.statLabel(
                    AppLocalizations.of(context),
                    stat.name,
                  ),
                  value: stat.baseStat,
                  maxValue: maxStat,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
