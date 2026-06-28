import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/pokemon_hero_tags.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/core/utils/pokemon_formatters.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';

class PokemonListCard extends StatelessWidget {
  const PokemonListCard({
    required this.number,
    required this.name,
    required this.types,
    super.key,
    this.spriteUrl,
    this.onTap,
  });

  final int number;
  final String name;
  final List<PokemonType> types;
  final String? spriteUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PokemonFormatters.displayNumber(number),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Expanded(
                child: Center(
                  child: spriteUrl != null
                      ? PokemonSpriteImage(
                          imageUrl: spriteUrl!,
                          height: PokemonSpriteDisplaySizes.listCard,
                          maxCachePixels: PokemonSpriteCachePresets.listRow,
                          heroTag: PokemonHeroTags.sprite(number),
                        )
                      : const Icon(Icons.catching_pokemon, size: 56),
                ),
              ),
              Text(
                name,
                style: theme.textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: types
                    .map(
                      (type) => PokemonTypeChip(type: type, showLabel: false),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
