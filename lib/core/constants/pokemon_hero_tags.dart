import 'package:flutter/material.dart';
import 'package:pokedex_app/features/shell/presentation/widgets/shell_tab_scope.dart';

abstract final class PokemonHeroTags {
  static String sprite(int pokemonId) => 'pokemon_sprite_$pokemonId';

  /// Resolves a list-row [Hero] tag without colliding across shell tabs.
  ///
  /// Pass [heroShellTabIndex] for lists inside the bottom-nav shell (0 = Pokédex,
  /// 2 = Favorites). Set [useHero] for root-navigator lists (e.g. regional Pokédex).
  static Object? listSpriteHeroTag(
    BuildContext context, {
    required int pokemonId,
    int? heroShellTabIndex,
    bool useHero = false,
  }) {
    if (useHero) return sprite(pokemonId);
    if (heroShellTabIndex == null) return null;

    final scope = context.dependOnInheritedWidgetOfExactType<ShellTabScope>();
    if (scope == null || scope.currentIndex != heroShellTabIndex) {
      return null;
    }
    return sprite(pokemonId);
  }
}
