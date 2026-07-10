import 'package:pokedex_app/core/constants/pokemon_types.dart';

class PokemonSummary {
  const PokemonSummary({
    required this.id,
    required this.slug,
    required this.name,
    required this.types,
    this.spriteUrl,
    this.height,
    this.weight,
    this.isDefault,
    this.isMega = false,
  });

  final int id;

  /// PokeAPI resource name (e.g. `pikachu`, `charizard-mega-x`).
  final String slug;

  /// Localized or formatted display name.
  final String name;
  final List<PokemonType> types;
  final String? spriteUrl;
  final int? height;
  final int? weight;

  /// From PokeAPI `pokemon.is_default`; null when cache predates metadata.
  final bool? isDefault;

  /// From PokeAPI `pokemon-form.is_mega` when [isDefault] is false.
  final bool isMega;

  String get displayName => name.isEmpty
      ? (slug.isEmpty ? '' : slug[0].toUpperCase() + slug.substring(1))
      : name;
}

class PokemonDetail {
  const PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.stats,
    required this.abilities,
    this.spriteUrl,
    this.flavorText,
    this.genderRate = -1,
    this.captureRate = 0,
    this.baseHappiness = 0,
    this.hatchCounter = 0,
    this.eggGroups = const [],
    this.category,
    this.flavorTextEntries = const [],
    this.generaEntries = const [],
  });

  final int id;
  final String name;
  final int height;
  final int weight;
  final List<PokemonType> types;
  final List<PokemonStat> stats;
  final List<PokemonAbility> abilities;
  final String? spriteUrl;
  final String? flavorText;
  final int genderRate;
  final int captureRate;
  final int baseHappiness;
  final int hatchCounter;
  final List<String> eggGroups;
  final String? category;
  final List<dynamic> flavorTextEntries;
  final List<dynamic> generaEntries;

  String get displayName =>
      name.isEmpty ? '' : name[0].toUpperCase() + name.substring(1);

  double get heightMeters => height / 10;
  double get weightKg => weight / 10;
}

class PokemonStat {
  const PokemonStat({required this.name, required this.baseStat});

  final String name;
  final int baseStat;
}

class PokemonAbility {
  const PokemonAbility({
    required this.name,
    required this.isHidden,
    String? slug,
  }) : slug = slug ?? name;

  final String name;
  final bool isHidden;

  /// PokeAPI ability resource name (e.g. `overgrow`); preserved after enrichment.
  final String slug;
}

class PokemonPage {
  const PokemonPage({
    required this.items,
    required this.totalCount,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<PokemonSummary> items;
  final int totalCount;
  final bool hasMore;
  final int nextOffset;
}

class PokemonListSlice {
  const PokemonListSlice({
    required this.ids,
    required this.totalCount,
    required this.hasMore,
    required this.nextOffset,
    this.fromCache = false,
  });

  final List<int> ids;
  final int totalCount;
  final bool hasMore;
  final int nextOffset;
  final bool fromCache;
}
