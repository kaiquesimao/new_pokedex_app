abstract final class PokemonSpriteUrls {
  static const String _base =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon';

  static String officialArtwork({required int pokemonId}) =>
      '$_base/other/official-artwork/$pokemonId.png';

  static String homeArtwork({required int pokemonId}) =>
      '$_base/other/home/$pokemonId.png';

  static final RegExp _homeArtworkPattern = RegExp(
    r'/sprites/pokemon/other/home/(\d+)\.png$',
  );

  /// Returns [officialArtwork] when [imageUrl] is a home sprite URL.
  static String? officialArtworkFallbackFor(String imageUrl) {
    final match = _homeArtworkPattern.firstMatch(imageUrl);
    if (match == null) return null;
    return officialArtwork(pokemonId: int.parse(match.group(1)!));
  }

  static final RegExp _lowResSpritePattern = RegExp(
    r'/sprites/pokemon/\d+\.png$',
  );

  static bool isLowResolutionSpriteUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return _lowResSpritePattern.hasMatch(url);
  }
}
