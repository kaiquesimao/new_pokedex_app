class PokemonListResponse {
  const PokemonListResponse({
    required this.count,
    required this.results,
    this.next,
  });
  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>? ?? [])
        .map((e) => NamedApiResource.fromJson(e as Map<String, dynamic>))
        .toList();

    return PokemonListResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      results: results,
    );
  }

  final int count;
  final String? next;
  final List<NamedApiResource> results;
}

class NamedApiResource {
  const NamedApiResource({required this.name, required this.url});
  factory NamedApiResource.fromJson(Map<String, dynamic> json) {
    return NamedApiResource(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  final String name;
  final String url;

  int? get id {
    final match = RegExp(r'/(\d+)/?$').firstMatch(url);
    return match == null ? null : int.tryParse(match.group(1)!);
  }
}

class PokemonFormResponse {
  const PokemonFormResponse({required this.isMega});

  factory PokemonFormResponse.fromJson(Map<String, dynamic> json) {
    return PokemonFormResponse(isMega: json['is_mega'] as bool? ?? false);
  }

  final bool isMega;
}

class PokemonResponse {
  const PokemonResponse({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.spriteUrl,
    required this.listSpriteUrl,
    this.isDefault = true,
    this.primaryFormId,
    this.isMega,
    this.speciesId,
  });

  factory PokemonResponse.fromJson(Map<String, dynamic> json) {
    final sprites = Map<String, dynamic>.from(
      json['sprites'] as Map<Object?, Object?>? ?? const {},
    );
    final other = Map<String, dynamic>.from(
      sprites['other'] as Map<Object?, Object?>? ?? const {},
    );
    final artwork = Map<String, dynamic>.from(
      other['official-artwork'] as Map<Object?, Object?>? ?? const {},
    );
    final frontDefault = sprites['front_default'] as String?;

    return PokemonResponse(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      height: json['height'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      types: (json['types'] as List<dynamic>? ?? [])
          .map((e) => PokemonTypeSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: (json['stats'] as List<dynamic>? ?? [])
          .map((e) => PokemonStatSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      abilities: (json['abilities'] as List<dynamic>? ?? [])
          .map((e) => PokemonAbilitySlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      spriteUrl: artwork['front_default'] as String? ?? frontDefault,
      listSpriteUrl: frontDefault ?? artwork['front_default'] as String?,
      isDefault: json['is_default'] as bool? ?? true,
      primaryFormId: _primaryFormId(json['forms']),
      isMega: json['is_mega'] as bool?,
      speciesId: json['species_id'] as int? ?? _resourceId(json['species']),
    );
  }

  final int id;
  final String name;
  final int height;
  final int weight;
  final List<PokemonTypeSlot> types;
  final List<PokemonStatSlot> stats;
  final List<PokemonAbilitySlot> abilities;
  final String? spriteUrl;
  final String? listSpriteUrl;
  final bool isDefault;
  final int? primaryFormId;
  final bool? isMega;

  /// Species id from `pokemon.species` (differs from [id] for forms/megas).
  final int? speciesId;

  PokemonResponse copyWith({bool? isMega}) {
    return PokemonResponse(
      id: id,
      name: name,
      height: height,
      weight: weight,
      types: types,
      stats: stats,
      abilities: abilities,
      spriteUrl: spriteUrl,
      listSpriteUrl: listSpriteUrl,
      isDefault: isDefault,
      primaryFormId: primaryFormId,
      isMega: isMega ?? this.isMega,
      speciesId: speciesId,
    );
  }

  static int? _resourceId(dynamic resource) {
    if (resource is! Map) return null;
    final url = resource['url'] as String? ?? '';
    final match = RegExp(r'/(\d+)/?$').firstMatch(url);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static int? _primaryFormId(dynamic forms) {
    if (forms is! List<dynamic> || forms.isEmpty) return null;
    final first = forms.first;
    if (first is! Map) return null;
    final url = first['url'] as String? ?? '';
    final match = RegExp(r'/(\d+)/?$').firstMatch(url);
    return match == null ? null : int.tryParse(match.group(1)!);
  }
}

class PokemonTypeSlot {
  const PokemonTypeSlot({required this.slot, required this.name});
  factory PokemonTypeSlot.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as Map<String, dynamic>? ?? {};
    return PokemonTypeSlot(
      slot: json['slot'] as int? ?? 0,
      name: type['name'] as String? ?? '',
    );
  }

  final int slot;
  final String name;
}

class PokemonStatSlot {
  const PokemonStatSlot({required this.name, required this.baseStat});
  factory PokemonStatSlot.fromJson(Map<String, dynamic> json) {
    final stat = json['stat'] as Map<String, dynamic>? ?? {};
    return PokemonStatSlot(
      name: stat['name'] as String? ?? '',
      baseStat: json['base_stat'] as int? ?? 0,
    );
  }

  final String name;
  final int baseStat;
}

class PokemonAbilitySlot {
  const PokemonAbilitySlot({required this.name, required this.isHidden});
  factory PokemonAbilitySlot.fromJson(Map<String, dynamic> json) {
    final ability = json['ability'] as Map<String, dynamic>? ?? {};
    return PokemonAbilitySlot(
      name: ability['name'] as String? ?? '',
      isHidden: json['is_hidden'] as bool? ?? false,
    );
  }

  final String name;
  final bool isHidden;
}

class PokemonSpeciesVariety {
  const PokemonSpeciesVariety({
    required this.isDefault,
    required this.pokemonId,
    required this.pokemonName,
  });

  factory PokemonSpeciesVariety.fromJson(Map<String, dynamic> json) {
    final pokemon = NamedApiResource.fromJson(
      json['pokemon'] as Map<String, dynamic>? ?? {},
    );
    return PokemonSpeciesVariety(
      isDefault: json['is_default'] as bool? ?? false,
      pokemonId: pokemon.id ?? 0,
      pokemonName: pokemon.name,
    );
  }

  final bool isDefault;
  final int pokemonId;
  final String pokemonName;
}

class PokemonSpeciesResponse {
  const PokemonSpeciesResponse({
    required this.id,
    required this.flavorText,
    required this.genderRate,
    required this.captureRate,
    required this.baseHappiness,
    required this.hatchCounter,
    required this.eggGroups,
    required this.evolutionChainUrl,
    this.varieties = const [],
  });
  factory PokemonSpeciesResponse.fromJson(Map<String, dynamic> json) {
    final entries = json['flavor_text_entries'] as List<dynamic>? ?? [];
    String? flavorText;

    for (final entry in entries) {
      final map = entry as Map<String, dynamic>;
      final language = map['language'] as Map<String, dynamic>? ?? {};
      final langName = language['name'] as String? ?? '';
      if (langName == 'en' || langName == 'pt') {
        flavorText = (map['flavor_text'] as String? ?? '')
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
        if (langName == 'pt') break;
      }
    }

    return PokemonSpeciesResponse(
      id: json['id'] as int? ?? 0,
      flavorText: flavorText,
      genderRate: json['gender_rate'] as int? ?? -1,
      captureRate: json['capture_rate'] as int? ?? 0,
      baseHappiness: json['base_happiness'] as int? ?? 0,
      hatchCounter: json['hatch_counter'] as int? ?? 0,
      eggGroups: (json['egg_groups'] as List<dynamic>? ?? [])
          .map((e) => (e as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      evolutionChainUrl:
          (json['evolution_chain'] as Map<String, dynamic>?)?['url'] as String?,
      varieties: (json['varieties'] as List<dynamic>? ?? [])
          .map(
            (e) => PokemonSpeciesVariety.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final int id;
  final String? flavorText;
  final int genderRate;
  final int captureRate;
  final int baseHappiness;
  final int hatchCounter;
  final List<String> eggGroups;
  final String? evolutionChainUrl;
  final List<PokemonSpeciesVariety> varieties;
}
