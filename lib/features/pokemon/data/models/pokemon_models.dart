import 'package:pokedex_app/core/constants/pokemon_sprite_urls.dart';
import 'package:pokedex_app/core/locale/poke_api_localized_text.dart';

class const PokemonListResponse({
  required final int count,
  required final List<NamedApiResource> results,
  final String? next,
}) {
  factory fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>? ?? [])
        .map((e) => NamedApiResource.fromJson(e as Map<String, dynamic>))
        .toList();

    return PokemonListResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      results: results,
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
}

class const PokemonCries({final String? latest, final String? legacy}) {
  factory fromJson(Map<String, dynamic>? json) {
    return switch (json) {
      null => const PokemonCries(),
      {'latest': final String? latest, 'legacy': final String? legacy} =>
        PokemonCries(latest: latest, legacy: legacy),
      {'latest': final String? latest} => PokemonCries(latest: latest),
      {'legacy': final String? legacy} => PokemonCries(legacy: legacy),
      _ => const PokemonCries(),
    };
  }
}

class const PokemonFormResponse({required final bool isMega}) {
  factory fromJson(Map<String, dynamic> json) {
    return PokemonFormResponse(isMega: json['is_mega'] as bool? ?? false);
  }
}

class const PokemonResponse({
  required final int id,
  required final String name,
  required final int height,
  required final int weight,
  required final List<PokemonTypeSlot> types,
  required final List<PokemonStatSlot> stats,
  required final List<PokemonAbilitySlot> abilities,
  required final String? spriteUrl,
  required final String? listSpriteUrl,
  final Map<String, dynamic>? sprites,
  final bool isDefault = true,
  final int? primaryFormId,
  final bool? isMega,

  /// Species id from `pokemon.species` (differs from [id] for forms/megas).
  final int? speciesId,
  final PokemonCries cries = const PokemonCries(),
}) {
  factory fromJson(Map<String, dynamic> json) {
    final spritesJson = json['sprites'];
    final spritesMap = spritesJson is Map<Object?, Object?>
        ? Map<String, dynamic>.from(spritesJson)
        : null;
    final parsed = PokemonSprites.fromJson(spritesMap);

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
      spriteUrl: parsed.displayUrl,
      listSpriteUrl: parsed.listUrl,
      sprites: spritesMap,
      isDefault: json['is_default'] as bool? ?? true,
      primaryFormId: _primaryFormId(json['forms']),
      isMega: json['is_mega'] as bool?,
      speciesId: json['species_id'] as int? ?? _resourceId(json['species']),
      cries: PokemonCries.fromJson(json['cries'] as Map<String, dynamic>?),
    );
  }

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
      sprites: sprites,
      isDefault: isDefault,
      primaryFormId: primaryFormId,
      isMega: isMega ?? this.isMega,
      speciesId: speciesId,
      cries: cries,
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

class const PokemonTypeSlot({
  required final int slot,
  required final String name,
}) {
  factory fromJson(Map<String, dynamic> json) {
    final type = json['type'] as Map<String, dynamic>? ?? {};
    return PokemonTypeSlot(
      slot: json['slot'] as int? ?? 0,
      name: type['name'] as String? ?? '',
    );
  }
}

class const PokemonStatSlot({
  required final String name,
  required final int baseStat,
}) {
  factory fromJson(Map<String, dynamic> json) {
    final stat = json['stat'] as Map<String, dynamic>? ?? {};
    return PokemonStatSlot(
      name: stat['name'] as String? ?? '',
      baseStat: json['base_stat'] as int? ?? 0,
    );
  }
}

class const PokemonAbilitySlot({
  required final String name,
  required final bool isHidden,
}) {
  factory fromJson(Map<String, dynamic> json) {
    final ability = json['ability'] as Map<String, dynamic>? ?? {};
    return PokemonAbilitySlot(
      name: ability['name'] as String? ?? '',
      isHidden: json['is_hidden'] as bool? ?? false,
    );
  }
}

class const PokemonSpeciesVariety({
  required final bool isDefault,
  required final int pokemonId,
  required final String pokemonName,
}) {
  factory fromJson(Map<String, dynamic> json) {
    final pokemon = NamedApiResource.fromJson(
      json['pokemon'] as Map<String, dynamic>? ?? {},
    );
    return PokemonSpeciesVariety(
      isDefault: json['is_default'] as bool? ?? false,
      pokemonId: pokemon.id ?? 0,
      pokemonName: pokemon.name,
    );
  }
}

class const PokemonSpeciesResponse({
  required final int id,
  required final List<dynamic> names,
  required final int genderRate,
  required final int captureRate,
  required final int baseHappiness,
  required final int hatchCounter,
  required final List<String> eggGroups,
  required final String? evolutionChainUrl,
  final List<dynamic> flavorTextEntries = const [],
  final String? legacyFlavorText,
  final List<PokemonSpeciesVariety> varieties = const [],
  final List<dynamic> genera = const [],
}) {
  /// ponytail: test/fixture shorthand — not from API JSON.
  factory withFlavorText({
    required int id,
    required String flavorText,
    int genderRate = -1,
    int captureRate = 0,
    int baseHappiness = 0,
    int hatchCounter = 0,
    List<String> eggGroups = const [],
    String? evolutionChainUrl,
    List<PokemonSpeciesVariety> varieties = const [],
    List<dynamic> names = const [],
    List<dynamic> genera = const [],
  }) {
    return PokemonSpeciesResponse(
      id: id,
      names: names,
      legacyFlavorText: flavorText,
      genderRate: genderRate,
      captureRate: captureRate,
      baseHappiness: baseHappiness,
      hatchCounter: hatchCounter,
      eggGroups: eggGroups,
      evolutionChainUrl: evolutionChainUrl,
      varieties: varieties,
      genera: genera,
    );
  }
  factory fromJson(Map<String, dynamic> json) {
    final names = json['names'] as List<dynamic>? ?? [];
    final flavorTextEntries =
        json['flavor_text_entries'] as List<dynamic>? ?? [];

    return PokemonSpeciesResponse(
      id: json['id'] as int? ?? 0,
      names: names,
      flavorTextEntries: flavorTextEntries,
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
      genera: json['genera'] as List<dynamic>? ?? [],
    );
  }

  String? localizedName(String pokeApiCode) {
    // Use PokeApiLocalizedText helper to pick localized name.
    return PokeApiLocalizedText.pickName(names, pokeApiCode);
  }

  String? localizedFlavorText(String pokeApiCode) {
    return PokeApiLocalizedText.pickFlavorText(
          flavorTextEntries,
          pokeApiCode,
        ) ??
        legacyFlavorText;
  }
}
