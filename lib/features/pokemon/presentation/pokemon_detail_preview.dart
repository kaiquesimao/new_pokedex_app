import 'package:pokedex_app/core/constants/pokemon_types.dart';

/// Sprite and name already known by the screen that opened the detail route.
class PokemonDetailPreview {
  const new({
    required this.id,
    required this.displayName,
    this.spriteUrl,
    this.types = const [],
  });

  final int id;
  final String displayName;
  final String? spriteUrl;
  final List<PokemonType> types;

  static PokemonDetailPreview? fromExtra(Object? extra, int pokemonId) {
    if (extra is! PokemonDetailPreview || extra.id != pokemonId) return null;
    final hasName = extra.displayName.trim().isNotEmpty;
    final spriteUrl = extra.spriteUrl;
    final hasSprite = spriteUrl != null && spriteUrl.isNotEmpty;
    if (!hasName && !hasSprite) return null;
    return extra;
  }
}

/// Full detail replaces the preview only after the route transition finishes,
/// so the landing hero is not recreated mid-flight.
bool showLoadedPokemonDetail({
  required bool hasBundle,
  required bool libraryReady,
  required bool hasPreview,
  required bool transitionSettled,
}) {
  if (!hasBundle || !libraryReady) return false;
  if (!hasPreview) return true;
  return transitionSettled;
}
