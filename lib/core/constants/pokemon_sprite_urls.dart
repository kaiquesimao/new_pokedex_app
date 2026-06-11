abstract final class PokemonSpriteUrls {
  static const String _base =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon';

  static String officialArtwork(int pokemonId) =>
      '$_base/other/official-artwork/$pokemonId.png';

  static final RegExp _lowResSpritePattern = RegExp(
    r'/sprites/pokemon/\d+\.png$',
  );

  static bool isLowResolutionSpriteUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return _lowResSpritePattern.hasMatch(url);
  }
}
