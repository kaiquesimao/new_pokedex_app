import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/analytics/app_analytics.dart';
import 'package:pokedex_app/core/constants/pokemon_hero_tags.dart';
import 'package:pokedex_app/core/network/network_errors.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/core/utils/pokemon_formatters.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/login_required_bottom_sheet.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_detail_bundle_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/utils/pokemon_detail_formatters.dart';
import 'package:pokedex_app/features/pokemon/presentation/widgets/pokemon_detail_about_section.dart';
import 'package:pokedex_app/features/pokemon/presentation/widgets/pokemon_weakness_section.dart';
import 'package:pokedex_app/shared/widgets/evolution_chain_node.dart';
import 'package:pokedex_app/shared/widgets/offline_banner.dart';
import 'package:pokedex_app/shared/widgets/pokemon_detail_skeleton.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';
import 'package:pokedex_app/shared/widgets/pokemon_stat_bar.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class PokemonDetailPage extends ConsumerWidget {
  const PokemonDetailPage({required this.pokemonId, super.key});

  final int pokemonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundleAsync = ref.watch(pokemonDetailBundleProvider(pokemonId));

    return bundleAsync.when(
      loading: () =>
          const Scaffold(body: SafePageBody(child: PokemonDetailSkeleton())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: SafePageBody.belowAppBar(
          child: OfflineEmptyState(
            message: friendlyErrorMessage(error),
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
      ),
    );
  }
}

class _PokemonDetailContent extends ConsumerStatefulWidget {
  const _PokemonDetailContent({
    required this.pokemonId,
    required this.pokemon,
    required this.evolution,
  });

  final int pokemonId;
  final PokemonDetail pokemon;
  final EvolutionChain evolution;

  @override
  ConsumerState<_PokemonDetailContent> createState() =>
      _PokemonDetailContentState();
}

class _PokemonDetailContentState extends ConsumerState<_PokemonDetailContent> {
  var _statsExpanded = true;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafePageBody(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HeroSection(
                pokemonId: widget.pokemonId,
                pokemon: pokemon,
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
              child: PokemonDetailAboutSection(pokemon: pokemon),
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

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.pokemonId,
    required this.pokemon,
    required this.headerColor,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final int pokemonId;
  final PokemonDetail pokemon;
  final Color headerColor;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PokemonSpriteLayoutSizes.detailHeaderHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  headerColor.withValues(alpha: 0.35),
                  headerColor.withValues(alpha: 0.08),
                  Theme.of(context).colorScheme.surface,
                ],
                radius: 0.85,
                center: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
                size: 28,
              ),
              onPressed: onFavoriteTap,
            ),
          ),
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: PokemonSpriteLayoutSizes.detailCircleSize,
                height: PokemonSpriteLayoutSizes.detailCircleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [headerColor, headerColor.withValues(alpha: 0.7)],
                  ),
                ),
                child: Center(
                  child: pokemon.spriteUrl != null
                      ? PokemonSpriteImage(
                          imageUrl: pokemon.spriteUrl!,
                          height: PokemonSpriteDisplaySizes.detail,
                          maxCachePixels: PokemonSpriteCachePresets.detail,
                          heroTag: PokemonHeroTags.sprite(pokemonId),
                          errorIconColor: Colors.white,
                          errorIconSize: 96,
                        )
                      : Hero(
                          tag: PokemonHeroTags.sprite(pokemonId),
                          child: const Material(
                            color: Colors.transparent,
                            child: Icon(
                              Icons.catching_pokemon,
                              size: 96,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evolução',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (evolution.isSingleStage)
            Column(
              children: [
                EvolutionChainNodeCard(node: evolution.root, isCurrent: true),
                const SizedBox(height: 12),
                Text(
                  'Este Pokémon não evolui.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            )
          else
            EvolutionChainTree(
              root: evolution.root,
              currentPokemonId: evolution.currentPokemonId,
              embedded: true,
              onNodeTap: (id) {
                if (id == pokemonId) return;
                unawaited(context.push('/pokemon/$id'));
              },
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
                    'Estatísticas',
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
                  label: PokemonDetailFormatters.statLabel(stat.name),
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
