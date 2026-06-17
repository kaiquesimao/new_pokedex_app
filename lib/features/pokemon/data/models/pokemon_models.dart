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
  });
  factory PokemonResponse.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>? ?? {};
    final other = sprites['other'] as Map<String, dynamic>? ?? {};
    final artwork = other['official-artwork'] as Map<String, dynamic>? ?? {};
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
}
