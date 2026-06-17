import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/constants/region_labels.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/regions/domain/utils/regional_pokemon_filter_utils.dart';
import 'package:pokedex_app/features/regions/presentation/providers/regional_pokedex_filters_provider.dart';
import 'package:pokedex_app/features/regions/presentation/providers/regional_pokedex_provider.dart';
import 'package:pokedex_app/features/regions/presentation/widgets/regional_filter_sheets.dart';
import 'package:pokedex_app/shared/widgets/offline_banner.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_card.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_skeleton.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_skeleton.dart';
import 'package:pokedex_app/shared/widgets/pokemon_search_bar.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class RegionalPokedexPage extends ConsumerWidget {
  const RegionalPokedexPage({required this.regionName, super.key});

  final String regionName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(regionalPokedexProvider(regionName));
    final filters = ref.watch(regionalPokedexFiltersProvider(regionName));
    final title = RegionLabels.label(regionName);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(title),
      ),
      body: SafePageBody.belowAppBar(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: PokemonSearchBar(
                initialValue: filters.searchQuery,
                onChanged: (query) => ref
                    .read(regionalPokedexFiltersProvider(regionName).notifier)
                    .update((current) => current.copyWith(searchQuery: query)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  _TypeFilterChip(
                    typeFilter: filters.typeFilter,
                    onTap: () => showRegionalTypeSheet(context, regionName),
                  ),
                  const SizedBox(width: 8),
                  _SortFilterChip(
                    sort: filters.sort,
                    onTap: () => showRegionalSortSheet(context, regionName),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(context, ref, state, filters)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    RegionalPokedexState state,
    PokemonListFilters filters,
  ) {
    if (state.showFullSkeleton) {
      return const PokemonListSkeleton();
    }

    if (state.error != null && state.items.isEmpty) {
      return OfflineEmptyState(
        message: state.error!,
        isConnectivityFailure: state.errorIsConnectivityFailure,
        onRetry: () => ref
            .read(regionalPokedexProvider(regionName).notifier)
            .load(regionName),
      );
    }

    final filtered = RegionalPokemonFilterUtils.apply(
      items: state.items,
      filters: filters,
    );

    if (filtered.isEmpty && !state.isLoadingSummaries) {
      return const Center(child: Text('Nenhum Pokémon encontrado'));
    }

    final skeletonCount = state.items.isNotEmpty && state.isLoadingSummaries
        ? 2
        : 0;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: filtered.length + skeletonCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= filtered.length) {
          return const PokemonListRowSkeleton();
        }

        final entry = filtered[index];
        return PokemonListRowCard(
          number: entry.regionalNumber,
          name: entry.displayName,
          types: entry.types,
          spriteUrl: entry.spriteUrl,
          heroPokemonId: entry.pokemonId,
          useHero: true,
          onTap: () => context.push('/pokemon/${entry.pokemonId}'),
        );
      },
    );
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
