import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/presentation/navigation/open_pokemon_detail.dart';
import 'package:pokedex_app/features/pokemon/presentation/pokemon_detail_preview.dart';
import 'package:pokedex_app/features/recent_pokemon/presentation/providers/recent_pokemon_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';

class RecentPokemonStrip extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(recentPokemonProvider);
    if (ids.isEmpty) return const SizedBox.shrink();

    final summaries =
        ref.watch(recentPokemonSummariesProvider).asData?.value ?? const [];
    if (summaries.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.recentPokemonTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () =>
                    ref.read(recentPokemonProvider.notifier).clear(),
                child: Text(l10n.recentPokemonClear),
              ),
            ],
          ),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: summaries.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return _RecentPokemonChip(summary: summaries[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPokemonChip extends StatelessWidget {
  const new({required this.summary});

  final PokemonSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryType = summary.types.isNotEmpty
        ? summary.types.first
        : PokemonType.normal;
    final typeColor = PokemonTypeColors.forType(primaryType, isDark: isDark);
    final cardFill = Color.alphaBlend(
      typeColor.withValues(alpha: isDark ? 0.34 : 0.22),
      theme.colorScheme.surface,
    );
    final l10n = AppLocalizations.of(context);
    final spriteUrl = summary.spriteUrl;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: l10n.recentPokemonOpenSemantics(summary.displayName),
      child: SizedBox(
        width: 92,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => openPokemonDetail(
              context,
              PokemonDetailPreview(
                id: summary.id,
                displayName: summary.displayName,
                spriteUrl: summary.spriteUrl,
                types: summary.types,
              ),
            ),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                color: cardFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: typeColor.withValues(alpha: isDark ? 0.4 : 0.28),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (spriteUrl != null && spriteUrl.isNotEmpty)
                      PokemonSpriteImage(
                        imageUrl: spriteUrl,
                        width: 44,
                        height: 44,
                        semanticLabel: summary.displayName,
                      )
                    else
                      const SizedBox(width: 44, height: 44),
                    const SizedBox(height: 2),
                    Text(
                      summary.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
