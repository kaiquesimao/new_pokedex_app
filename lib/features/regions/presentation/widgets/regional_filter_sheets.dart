import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/locale/pokemon_filters_l10n.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/regions/presentation/providers/regional_pokedex_filters_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/all_types_chip.dart';
import 'package:pokedex_app/shared/widgets/bottom_sheet_header.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';

Future<void> showRegionalTypeSheet(BuildContext context, String regionName) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _RegionalTypeSheet(regionName: regionName),
  );
}

Future<void> showRegionalSortSheet(BuildContext context, String regionName) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (context) => _RegionalSortSheet(regionName: regionName),
  );
}

class _RegionalTypeSheet extends ConsumerWidget {
  const _RegionalTypeSheet({required this.regionName});

  final String regionName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(regionalPokedexFiltersProvider(regionName));
    final notifier = ref.read(
      regionalPokedexFiltersProvider(regionName).notifier,
    );
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            BottomSheetHeader(
              title: l10n.filterTypesTitle,
              onClear: () {
                notifier.update(
                  (current) => current.copyWith(clearTypeFilter: true),
                );
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
                      notifier.update(
                        (current) => current.copyWith(clearTypeFilter: true),
                      );
                      Navigator.pop(context);
                    },
                  ),
                  ...PokemonType.values.map((type) {
                    final selected = filters.typeFilter == type;
                    return PokemonTypeChip(
                      type: type,
                      selected: selected,
                      onTap: () {
                        notifier.update(
                          (current) => current.copyWith(
                            typeFilter: selected ? null : type,
                            clearTypeFilter: selected,
                          ),
                        );
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RegionalSortSheet extends ConsumerWidget {
  const _RegionalSortSheet({required this.regionName});

  final String regionName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(regionalPokedexFiltersProvider(regionName));
    final notifier = ref.read(
      regionalPokedexFiltersProvider(regionName).notifier,
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHeader(title: l10n.filterSortTitle),
          ...PokemonSortOption.values.map((option) {
            final selected = filters.sort == option;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SizedBox(
                width: double.infinity,
                child: _SortPill(
                  label: option.label(l10n),
                  selected: selected,
                  onTap: () {
                    notifier.update(
                      (current) => current.copyWith(sort: option),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          }),
        ],
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
