/// Ordered cry URLs to try when playing a Pokémon cry.
List<String> pokemonCryPlaybackUrls({
  String? cryUrl,
  String? legacyCryUrl,
  int? pokemonId,
}) {
  final latest =
      _nonEmpty(cryUrl) ??
      (pokemonId == null
          ? null
          : 'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/$pokemonId.ogg');
  final legacy =
      _nonEmpty(legacyCryUrl) ??
      (pokemonId == null
          ? null
          : 'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/legacy/$pokemonId.ogg');

  return [latest, legacy].whereType<String>().toList(growable: false);
}

String? _nonEmpty(String? value) {
  if (value == null || value.isEmpty) return null;
  return value;
}
