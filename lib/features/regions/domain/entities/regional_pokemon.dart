import 'package:pokedex_app/core/constants/pokemon_types.dart';

class const RegionalPokemon({
  required final int regionalNumber,
  required final int pokemonId,
  required final String name,
  required final List<PokemonType> types,
  final String? spriteUrl,
}) {
  String get displayName =>
      name.isEmpty ? '' : name[0].toUpperCase() + name.substring(1);
}
