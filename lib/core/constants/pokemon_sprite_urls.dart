/// Parsed Pokémon sprite URLs from a PokéAPI `sprites` object.
class const PokemonSprites({
  final String? frontDefault,
  final String? officialArtwork,
  final String? home,
  final String? frontShiny,
  final String? officialArtworkShiny,
  final String? homeShiny,
}) {
  factory fromJson(dynamic sprites) {
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
      frontShiny: map['front_shiny'] as String?,
      officialArtworkShiny: artwork['front_shiny'] as String?,
      homeShiny: homeMap['front_shiny'] as String?,
    );
  }

  /// Primary display URL: home → official-artwork → front_default.
  String? get displayUrl => home ?? officialArtwork ?? frontDefault;

  /// Compact list URL: front_default → official-artwork → home.
  String? get listUrl => frontDefault ?? officialArtwork ?? home;

  /// Shiny display URL: home shiny → official-artwork shiny → front_shiny.
  String? get shinyDisplayUrl =>
      homeShiny ?? officialArtworkShiny ?? frontShiny;
}

/// Helpers for Pokémon sprite URLs supplied by PokéAPI responses.
abstract final class PokemonSpriteUrls {
  static const _homeSegment = '/other/home/';
  static const _officialSegment = '/other/official-artwork/';
  static const _homeSpriteBase =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home';
  static const _officialArtworkBase =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';

  static final RegExp _lowResSpritePattern = RegExp(
    r'/sprites/pokemon/\d+\.png$',
  );
  static final RegExp _spriteIdPattern = RegExp(r'/(\d+)\.png(?:\?|$)');

  /// Home sprite used by the Pokédex list and guessing game (matches [PokemonSprites.displayUrl]).
  static String homeSpriteForId(int id) => '$_homeSpriteBase/$id.png';

  /// Official artwork fallback when a home sprite fails to load.
  static String officialArtworkForId(int id) => '$_officialArtworkBase/$id.png';

  /// Resolves the same high-quality sprite the home Pokédex shows (home).
  ///
  /// Upgrades low-resolution or official-artwork URLs to home when an id is known.
  static String highQualitySpriteUrl(String imageUrl, {int? speciesId}) {
    final id = speciesId ?? idFromSpriteUrl(imageUrl);
    if (id == null) return imageUrl;
    if (imageUrl.contains(_homeSegment)) return imageUrl;
    return homeSpriteForId(id);
  }

  static int? idFromSpriteUrl(String imageUrl) {
    final match = _spriteIdPattern.firstMatch(imageUrl);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

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
