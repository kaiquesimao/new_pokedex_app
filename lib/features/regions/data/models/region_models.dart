class RegionListResponse {
  const RegionListResponse({required this.results});

  final List<NamedApiResource> results;

  factory RegionListResponse.fromJson(Map<String, dynamic> json) {
    return RegionListResponse(
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => NamedApiResource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RegionDetailResponse {
  const RegionDetailResponse({
    required this.id,
    required this.name,
    required this.pokedexes,
  });

  final int id;
  final String name;
  final List<NamedApiResource> pokedexes;

  factory RegionDetailResponse.fromJson(Map<String, dynamic> json) {
    return RegionDetailResponse(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      pokedexes: (json['pokedexes'] as List<dynamic>? ?? [])
          .map((e) => NamedApiResource.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PokedexResponse {
  const PokedexResponse({
    required this.id,
    required this.name,
    required this.pokemonEntries,
  });

  final int id;
  final String name;
  final List<PokedexEntryResponse> pokemonEntries;

  factory PokedexResponse.fromJson(Map<String, dynamic> json) {
    return PokedexResponse(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      pokemonEntries: (json['pokemon_entries'] as List<dynamic>? ?? [])
          .map((e) => PokedexEntryResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PokedexEntryResponse {
  const PokedexEntryResponse({
    required this.entryNumber,
    required this.pokemonSpecies,
  });

  final int entryNumber;
  final NamedApiResource pokemonSpecies;

  factory PokedexEntryResponse.fromJson(Map<String, dynamic> json) {
    return PokedexEntryResponse(
      entryNumber: json['entry_number'] as int? ?? 0,
      pokemonSpecies: NamedApiResource.fromJson(
        json['pokemon_species'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class NamedApiResource {
  const NamedApiResource({required this.name, required this.url});

  final String name;
  final String url;

  factory NamedApiResource.fromJson(Map<String, dynamic> json) {
    return NamedApiResource(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  int? get id {
    final match = RegExp(r'/(\d+)/?$').firstMatch(url);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  String get displayName =>
      name.isEmpty ? '' : name[0].toUpperCase() + name.substring(1);
}
