import 'package:pokedex_app/core/constants/pokemon_types.dart';

class const PokemonSummary({
  required final int id,
  required final String slug,
  required final String name,
  required final List<PokemonType> types,
  final String? spriteUrl,
  final String? shinySpriteUrl,
  final int? height,
  final int? weight,
  final bool? isDefault,
  final bool isMega = false,
}) {
  /// PokeAPI resource name lives in [slug] (e.g. `pikachu`).
  String get displayName => name.isEmpty
      ? (slug.isEmpty ? '' : slug[0].toUpperCase() + slug.substring(1))
      : name;
}

class const PokemonDetail({
  required final int id,
  required final String name,
  required final int height,
  required final int weight,
  required final List<PokemonType> types,
  required final List<PokemonStat> stats,
  required final List<PokemonAbility> abilities,
  final String? spriteUrl,
  final String? cryUrl,
  final String? legacyCryUrl,
  final String? flavorText,
  final int genderRate = -1,
  final int captureRate = 0,
  final int baseHappiness = 0,
  final int hatchCounter = 0,
  final List<String> eggGroups = const [],
  final String? category,
  final List<dynamic> flavorTextEntries = const [],
  final List<dynamic> generaEntries = const [],
}) {
  String get displayName =>
      name.isEmpty ? '' : name[0].toUpperCase() + name.substring(1);

  double get heightMeters => height / 10;
  double get weightKg => weight / 10;
}

class const PokemonStat({
  required final String name,
  required final int baseStat,
});

class PokemonAbility {
  const new({
    required this.name,
    required this.isHidden,
    String? slug,
  }) : slug = slug ?? name;

  final String name;
  final bool isHidden;

  /// PokeAPI ability resource name (e.g. `overgrow`); preserved after enrichment.
  final String slug;
}

class const PokemonPage({
  required final List<PokemonSummary> items,
  required final int totalCount,
  required final bool hasMore,
  required final int nextOffset,
});

class const PokemonListSlice({
  required final List<int> ids,
  required final int totalCount,
  required final bool hasMore,
  required final int nextOffset,
  final bool fromCache = false,
});
