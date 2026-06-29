import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/core/utils/pokemon_formatters.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/shared/widgets/pokemon_primary_type_backdrop.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_icon.dart';

class EvolutionChainNodeCard extends StatelessWidget {
  const EvolutionChainNodeCard({
    required this.node,
    required this.isCurrent,
    super.key,
    this.isFinalStage = false,
    this.onTap,
  });

  final EvolutionChainNode node;
  final bool isCurrent;
  final bool isFinalStage;
  final VoidCallback? onTap;

  static const double _cardHeight = 96;
  static const double _spritePanelWidth = 108;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryType = node.types.isNotEmpty
        ? node.types.first
        : PokemonType.normal;
    final typeColor = PokemonTypeColors.forType(primaryType, isDark: isDark);
    final spriteHeight = isFinalStage ? 108.0 : 72.0;
    final ovalWidth = isFinalStage ? 96.0 : 84.0;
    final ovalHeight = isFinalStage ? 88.0 : 72.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: _cardHeight,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isDark
                  ? theme.dividerColor
                  : AppColorsLight.textSecondary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: _spritePanelWidth,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: ovalWidth,
                      height: ovalHeight,
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: PokemonPrimaryTypeBackdrop(
                          type: primaryType,
                          size: isFinalStage ? 72 : 56,
                        ),
                      ),
                    ),
                    if (node.spriteUrl != null)
                      PokemonSpriteImage(
                        imageUrl: node.spriteUrl!,
                        height: spriteHeight,
                        maxCachePixels: PokemonSpriteCachePresets.evolution,
                        errorIconColor: Colors.white70,
                      )
                    else
                      Icon(
                        Icons.catching_pokemon,
                        size: isFinalStage ? 64 : 48,
                        color: Colors.white70,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      node.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (node.speciesId != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        PokemonFormatters.displayNumber(node.speciesId!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColorsLight.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (node.types.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: node.types
                            .map((type) => _EvolutionTypeBadge(type: type))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EvolutionTypeBadge extends StatelessWidget {
  const _EvolutionTypeBadge({required this.type});

  final PokemonType type;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = PokemonTypeColors.forType(type, isDark: isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        child: PokemonTypeIcon(assetPath: type.assetPath, size: 14),
      ),
    );
  }
}

class EvolutionChainConnector extends StatelessWidget {
  const EvolutionChainConnector({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_downward_rounded,
            color: AppColorsLight.primary,
            size: 28,
          ),
          if (label != null && label!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColorsLight.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EvolutionChainTree extends StatelessWidget {
  const EvolutionChainTree({
    required this.root,
    required this.currentPokemonId,
    super.key,
    this.onNodeTap,
    this.embedded = false,
  });

  final EvolutionChainNode root;
  final int currentPokemonId;
  final ValueChanged<int>? onNodeTap;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = _buildNode(context, root);
    if (embedded) return content;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  Widget _buildNode(BuildContext context, EvolutionChainNode node) {
    final children = node.evolvesTo;
    final isFinalStage = children.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EvolutionChainNodeCard(
          node: node,
          isCurrent: node.speciesId == currentPokemonId,
          isFinalStage: isFinalStage,
          onTap: node.speciesId == null
              ? null
              : () => onNodeTap?.call(node.speciesId!),
        ),
        if (children.length == 1) ...[
          EvolutionChainConnector(label: children.first.trigger?.displayLabel),
          _buildNode(context, children.first),
        ] else if (children.length > 1) ...[
          const EvolutionChainConnector(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children.map((child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      if (child.trigger?.displayLabel.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            child.trigger!.displayLabel,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColorsLight.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      _buildNode(context, child),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
