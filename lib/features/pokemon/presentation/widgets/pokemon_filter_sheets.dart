import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/analytics/app_analytics.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/locale/pokemon_filters_l10n.dart';
import 'package:pokedex_app/core/locale/pokemon_type_l10n.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_filters_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/all_types_chip.dart';
import 'package:pokedex_app/shared/widgets/bottom_sheet_header.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';
import 'package:pokedex_app/shared/widgets/sort_option_chip.dart';

Future<void> showPokemonTypeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _PokemonTypeSheet(),
  );
}

Future<void> showPokemonFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _PokemonFilterSheet(),
  );
}

Future<void> showPokemonSortSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    builder: (context) => const _PokemonSortSheet(),
  );
}

Future<void> showPokemonGenerationSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _PokemonGenerationSheet(),
  );
}

class _PokemonTypeSheet extends ConsumerWidget {
  const _PokemonTypeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(pokemonFiltersProvider);
    final notifier = ref.read(pokemonFiltersProvider.notifier);

    final l10n = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Semantics(
          label: l10n.filterTypeSemantics,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              BottomSheetHeader(
                title: l10n.filterTypesTitle,
                onClear: () {
                  notifier.setTypeFilter(null);
                  ref.read(appAnalyticsProvider).filterType();
                  Navigator.pop(context);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AllTypesChip(
                      selected: filters.typeFilter == null,
                      onTap: () {
                        notifier.setTypeFilter(null);
                        ref.read(appAnalyticsProvider).filterType();
                        Navigator.pop(context);
                      },
                    ),
                    ...PokemonType.values.map((type) {
                      final selected = filters.typeFilter == type;
                      return PokemonTypeChip(
                        type: type,
                        selected: selected,
                        onTap: () {
                          final next = selected ? null : type;
                          notifier.setTypeFilter(next);
                          ref
                              .read(appAnalyticsProvider)
                              .filterType(typeName: next?.label(l10n));
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PokemonFilterSheet extends ConsumerWidget {
  const _PokemonFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(pokemonFiltersProvider);
    final notifier = ref.read(pokemonFiltersProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            BottomSheetHeader(
              title: l10n.filterAdvancedTitle,
              onClear: () {
                notifier.clearAll();
                Navigator.pop(context);
              },
            ),
            _SectionTitle(title: l10n.filterWeaknessTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PokemonType.values.map((type) {
                  final selected = filters.weakness == type;
                  return PokemonTypeChip(
                    type: type,
                    selected: selected,
                    onTap: () => notifier.setWeakness(selected ? null : type),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: l10n.filterHeightTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PokemonHeightBucket.values.map((bucket) {
                  final selected = filters.heightBucket == bucket;
                  return SortOptionChip(
                    label: bucket.label(l10n),
                    selected: selected,
                    onTap: () =>
                        notifier.setHeightBucket(selected ? null : bucket),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: l10n.filterWeightTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PokemonWeightBucket.values.map((bucket) {
                  final selected = filters.weightBucket == bucket;
                  return SortOptionChip(
                    label: bucket.label(l10n),
                    selected: selected,
                    onTap: () =>
                        notifier.setWeightBucket(selected ? null : bucket),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PokemonSortSheet extends ConsumerWidget {
  const _PokemonSortSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(pokemonFiltersProvider);
    final notifier = ref.read(pokemonFiltersProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.filterSortSemantics,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomSheetHeader(title: l10n.filterSortTitle),
            ...PokemonSortOption.values.map((option) {
              final selected = filters.sort == option;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: _SortPill(
                    label: option.label(l10n),
                    selected: selected,
                    onTap: () {
                      notifier.setSort(option);
                      ref
                          .read(appAnalyticsProvider)
                          .sortChanged(sortLabel: option.label(l10n));
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SortPill extends StatelessWidget {
  const _SortPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColorsLight.primary
              : AppColorsLight.sortPillDark,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _PokemonGenerationSheet extends ConsumerWidget {
  const _PokemonGenerationSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(pokemonFiltersProvider);
    final notifier = ref.read(pokemonFiltersProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            BottomSheetHeader(
              title: l10n.filterGenerationLabel,
              onClear: () {
                notifier.setGeneration(null);
                Navigator.pop(context);
              },
            ),
            ...kPokemonGenerationIds.map((generationId) {
              final selected = filters.generationId == generationId;
              return ListTile(
                title: Text(l10n.generationPickerLabel(generationId)),
                trailing: selected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  notifier.setGeneration(selected ? null : generationId);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
