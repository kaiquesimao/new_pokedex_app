import 'package:flutter/material.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';

class EvolutionChainNodeCard extends StatelessWidget {
  const EvolutionChainNodeCard({
    super.key,
    required this.node,
    required this.isCurrent,
    this.onTap,
  });

  final EvolutionChainNode node;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: PokemonSpriteLayoutSizes.evolutionCardWidth,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrent
                ? primary.withValues(alpha: 0.12)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent ? primary : theme.dividerColor,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (node.spriteUrl != null)
                PokemonSpriteImage(
                  imageUrl: node.spriteUrl!,
                  height: PokemonSpriteDisplaySizes.evolution,
                  maxCachePixels: PokemonSpriteCachePresets.evolution,
                )
              else
                const Icon(Icons.catching_pokemon, size: 56),
              const SizedBox(height: 8),
              Text(
                node.displayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EvolutionChainConnector extends StatelessWidget {
  const EvolutionChainConnector({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(
            Icons.arrow_downward_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          if (label != null && label!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
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
    super.key,
    required this.root,
    required this.currentPokemonId,
    this.onNodeTap,
    this.embedded = false,
  });

  final EvolutionChainNode root;
  final int currentPokemonId;
  final ValueChanged<int>? onNodeTap;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = Center(child: _buildNode(context, root));
    if (embedded) return content;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  Widget _buildNode(BuildContext context, EvolutionChainNode node) {
    final children = node.evolvesTo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EvolutionChainNodeCard(
          node: node,
          isCurrent: node.speciesId == currentPokemonId,
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
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
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
