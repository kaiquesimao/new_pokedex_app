import 'package:pokedex_app/core/constants/pokemon_types.dart';

class RegionalPokemon {
  const RegionalPokemon({
    required this.regionalNumber,
    required this.pokemonId,
    required this.name,
    required this.types,
    this.spriteUrl,
  });

  final int regionalNumber;
  final int pokemonId;
  final String name;
  final List<PokemonType> types;
  final String? spriteUrl;

  String get displayName =>
      name.isEmpty ? '' : name[0].toUpperCase() + name.substring(1);
}
