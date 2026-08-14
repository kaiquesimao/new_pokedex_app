class const RegionListResponse({
  required final List<NamedApiResource> results,
}) {
  factory fromJson(Map<String, dynamic> json) {
    return RegionListResponse(
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => NamedApiResource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class const RegionDetailResponse({
  required final int id,
  required final String name,
  required final List<NamedApiResource> pokedexes,
}) {
  factory fromJson(Map<String, dynamic> json) {
    return RegionDetailResponse(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      pokedexes: (json['pokedexes'] as List<dynamic>? ?? [])
          .map((e) => NamedApiResource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class const PokedexResponse({
  required final int id,
  required final String name,
  required final List<PokedexEntryResponse> pokemonEntries,
}) {
  factory fromJson(Map<String, dynamic> json) {
    return PokedexResponse(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      pokemonEntries: (json['pokemon_entries'] as List<dynamic>? ?? [])
          .map((e) => PokedexEntryResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class const PokedexEntryResponse({
  required final int entryNumber,
  required final NamedApiResource pokemonSpecies,
}) {
  factory fromJson(Map<String, dynamic> json) {
    return PokedexEntryResponse(
      entryNumber: json['entry_number'] as int? ?? 0,
      pokemonSpecies: NamedApiResource.fromJson(
        json['pokemon_species'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class const NamedApiResource({
  required final String name,
  required final String url,
}) {
  factory fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'name': final String name, 'url': final String url} => NamedApiResource(
        name: name,
        url: url,
      ),
      {'name': final String name} => NamedApiResource(name: name, url: ''),
      {'url': final String url} => NamedApiResource(name: '', url: url),
      _ => const NamedApiResource(name: '', url: ''),
    };
  }

  int? get id {
    final match = RegExp(r'/(\d+)/?$').firstMatch(url);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  String get displayName =>
      name.isEmpty ? '' : name[0].toUpperCase() + name.substring(1);
}
