enum PokemonType {
  normal('normal', 'normal'),
  fire('fire', 'fire'),
  water('water', 'water'),
  grass('grass', 'leaf'),
  electric('electric', 'electric'),
  ice('ice', 'ice'),
  fighting('fighting', 'fighting'),
  poison('poison', 'poison'),
  ground('ground', 'ground'),
  flying('flying', 'flying'),
  psychic('psychic', 'psychic'),
  bug('bug', 'bug'),
  rock('rock', 'rock'),
  ghost('ghost', 'ghost'),
  dragon('dragon', 'dragon'),
  dark('dark', 'dark'),
  steel('steel', 'steel'),
  fairy('fairy', 'fairy');

  const PokemonType(this.apiName, this.assetName);

  final String apiName;
  final String assetName;

  static PokemonType? fromApiName(String name) {
    final normalized = name.toLowerCase();
    for (final type in PokemonType.values) {
      if (type.apiName == normalized) {
        return type;
      }
    }
    return null;
  }

  String get assetPath => 'assets/images/elements/$assetName.png';

  String get labelPt => switch (this) {
    PokemonType.normal => 'Normal',
    PokemonType.fire => 'Fogo',
    PokemonType.water => 'Água',
    PokemonType.grass => 'Grama',
    PokemonType.electric => 'Elétrico',
    PokemonType.ice => 'Gelo',
    PokemonType.fighting => 'Lutador',
    PokemonType.poison => 'Veneno',
    PokemonType.ground => 'Terra',
    PokemonType.flying => 'Voador',
    PokemonType.psychic => 'Psíquico',
    PokemonType.bug => 'Inseto',
    PokemonType.rock => 'Pedra',
    PokemonType.ghost => 'Fantasma',
    PokemonType.dragon => 'Dragão',
    PokemonType.dark => 'Sombrio',
    PokemonType.steel => 'Aço',
    PokemonType.fairy => 'Fada',
  };
}
