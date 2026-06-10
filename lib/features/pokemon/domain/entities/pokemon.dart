import 'package:pokedex_app/core/constants/pokemon_types.dart';

class PokemonSummary {
  const PokemonSummary({
    required this.id,
    required this.name,
    required this.types,
    this.spriteUrl,
    this.height,
    this.weight,
  });

  final int id;
  final String name;
  final List<PokemonType> types;
  final String? spriteUrl;
  final int? height;
  final int? weight;

  String get displayName =>
      name.isEmpty ? '' : name[0].toUpperCase() + name.substring(1);
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
  const PokemonAbility({required this.name, required this.isHidden});

  final String name;
  final bool isHidden;
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
  });

  final List<int> ids;
  final int totalCount;
  final bool hasMore;
  final int nextOffset;
}
