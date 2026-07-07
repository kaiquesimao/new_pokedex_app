import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/analytics/app_analytics.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/widgets/login_required_bottom_sheet.dart';
import 'package:pokedex_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_filters_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_list_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/widgets/pokemon_filter_sheets.dart';
import 'package:pokedex_app/shared/widgets/offline_banner.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_card.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_skeleton.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_skeleton.dart';
import 'package:pokedex_app/shared/widgets/pokemon_search_bar.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class PokemonListPage extends ConsumerStatefulWidget {
  const PokemonListPage({super.key});

  @override
  ConsumerState<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends ConsumerState<PokemonListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final state = ref.read(pokemonListProvider);
      if (state.items.isEmpty &&
          !state.isLoadingIds &&
          !state.isLoadingSummaries) {
        unawaited(ref.read(pokemonListProvider.notifier).loadInitial());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      unawaited(ref.read(pokemonListProvider.notifier).loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pokemonListProvider);
    final filters = ref.watch(pokemonFiltersProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      body: SafePageBody(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: PokemonSearchBar(
                initialValue: filters.searchQuery,
                onChanged: ref.read(pokemonFiltersProvider.notifier).setSearch,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TypeFilterChip(
                      typeFilter: filters.typeFilter,
                      onTap: () => showPokemonTypeSheet(context),
                    ),
                    const SizedBox(width: 8),
                    _SortFilterChip(
                      sort: filters.sort,
                      onTap: () => showPokemonSortSheet(context),
                    ),
                    const SizedBox(width: 8),
                    _FilterPillChip(
                      label: 'Geração',
                      icon: Icons.layers_outlined,
                      onTap: () => showPokemonGenerationSheet(context),
                    ),
                    const SizedBox(width: 8),
                    _FilterPillChip(
                      label: 'Filtros Avançados',
                      icon: Icons.tune,
                      badgeCount: _advancedFilterCount(filters),
                      onTap: () => showPokemonFilterSheet(context),
                    ),
                  ],
                ),
              ),
            ),
            if (filters.generationId != null)
              _ActiveFilterChip(
                label: _generationLabel(filters.generationId!),
                onClear: () => ref
                    .read(pokemonFiltersProvider.notifier)
                    .setGeneration(null),
              ),
            Expanded(child: _buildBody(state, favorites)),
          ],
        ),
      ),
    );
  }

  int _advancedFilterCount(PokemonListFilters filters) {
    var count = 0;
    if (filters.weakness != null) count++;
    if (filters.heightBucket != null) count++;
    if (filters.weightBucket != null) count++;
    return count;
  }

  String _generationLabel(int id) {
    return kPokemonGenerations
        .firstWhere(
          (generation) => generation.id == id,
          orElse: () => (id: id, label: 'Geração $id'),
        )
        .label;
  }

  Widget _buildBody(PokemonListState state, Set<int> favorites) {
    if (state.showFullSkeleton) {
      return const PokemonListSkeleton();
    }

    if (state.error != null &&
        state.items.isEmpty &&
        !state.isLoadingSummaries &&
        !state.isLoadingIds) {
      return OfflineEmptyState(
        message: state.error!,
        isConnectivityFailure: state.errorIsConnectivityFailure,
        onRetry: () => ref.read(pokemonListProvider.notifier).loadInitial(),
      );
    }

    if (state.items.isEmpty &&
        !state.isLoadingSummaries &&
        !state.isLoadingIds) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48),
            SizedBox(height: 12),
            Text('Nenhum Pokémon encontrado'),
          ],
        ),
      );
    }

    final skeletonCount =
        state.items.isNotEmpty &&
            (state.isLoadingSummaries || state.isLoadingMore)
        ? 2
        : 0;

    return RefreshIndicator(
      onRefresh: () => ref.read(pokemonListProvider.notifier).loadInitial(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList.separated(
              itemCount: state.items.length + skeletonCount,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const PokemonListRowSkeleton();
                }

                final pokemon = state.items[index];
                return PokemonListRowCard(
                  number: pokemon.id,
                  name: pokemon.displayName,
                  types: pokemon.types,
                  spriteUrl: pokemon.spriteUrl,
                  isFavorite: favorites.contains(pokemon.id),
                  heroShellTabIndex: 0,
                  onTap: () => context.push('/pokemon/${pokemon.id}'),
                  onFavoriteTap: () => _toggleFavorite(context, pokemon.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(BuildContext context, int pokemonId) {
    if (!ref.read(authProvider).isAuthenticated) {
      unawaited(showLoginRequiredBottomSheet(context));
      return;
    }

    final favorites = ref.read(favoritesProvider);
    final willFavorite = !favorites.contains(pokemonId);
    unawaited(ref.read(favoritesProvider.notifier).toggle(pokemonId));
    ref
        .read(appAnalyticsProvider)
        .favoriteToggled(pokemonId: pokemonId, isFavorite: willFavorite);
  }
}

class _TypeFilterChip extends StatelessWidget {
  const _TypeFilterChip({required this.typeFilter, required this.onTap});

  final PokemonType? typeFilter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = typeFilter?.labelPt ?? 'Tipo';
    final color = typeFilter != null
        ? PokemonTypeColors.forType(typeFilter!, isDark: isDark)
        : AppColorsLight.sortPillDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: typeFilter != null ? color : AppColorsLight.sortPillDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _SortFilterChip extends StatelessWidget {
  const _SortFilterChip({required this.sort, required this.onTap});

  final PokemonSortOption sort;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColorsLight.sortPillDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              sort.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPillChip extends StatelessWidget {
  const _FilterPillChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final chip = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColorsLight.sortPillDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );

    if (badgeCount <= 0) return chip;

    return Badge(
      label: Text('$badgeCount'),
      child: chip,
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: InputChip(label: Text(label), onDeleted: onClear),
      ),
    );
  }
}
