/// Parsed Pokémon sprite URLs from a PokéAPI `sprites` object.
class PokemonSprites {
  const PokemonSprites({
    this.frontDefault,
    this.officialArtwork,
    this.home,
  });

  factory PokemonSprites.fromJson(dynamic sprites) {
    if (sprites is! Map) return const PokemonSprites();

    final map = Map<String, dynamic>.from(sprites);
    final other = Map<String, dynamic>.from(
      map['other'] as Map<Object?, Object?>? ?? const {},
    );
    final artwork = Map<String, dynamic>.from(
      other['official-artwork'] as Map<Object?, Object?>? ?? const {},
    );
    final homeMap = Map<String, dynamic>.from(
      other['home'] as Map<Object?, Object?>? ?? const {},
    );

    return PokemonSprites(
      frontDefault: map['front_default'] as String?,
      officialArtwork: artwork['front_default'] as String?,
      home: homeMap['front_default'] as String?,
    );
  }

  final String? frontDefault;
  final String? officialArtwork;
  final String? home;

  /// Primary display URL: home → official-artwork → front_default.
  String? get displayUrl => home ?? officialArtwork ?? frontDefault;

  /// Compact list URL: front_default → official-artwork → home.
  String? get listUrl => frontDefault ?? officialArtwork ?? home;
}

/// Helpers for Pokémon sprite URLs supplied by PokéAPI responses.
abstract final class PokemonSpriteUrls {
  static const _homeSegment = '/other/home/';
  static const _officialSegment = '/other/official-artwork/';

  static final RegExp _lowResSpritePattern = RegExp(
    r'/sprites/pokemon/\d+\.png$',
  );

  /// Returns official-artwork when [imageUrl] is a home sprite URL.
  static String? officialArtworkFallbackFor(String imageUrl) {
    if (!imageUrl.contains(_homeSegment)) return null;
    return imageUrl.replaceFirst(_homeSegment, _officialSegment);
  }

  static bool isLowResolutionSpriteUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return _lowResSpritePattern.hasMatch(url);
  }
}
