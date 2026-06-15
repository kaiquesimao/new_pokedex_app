import 'package:pokedex_app/core/constants/app_assets.dart';

enum PokemonType {
  normal('normal'),
  fire('fire'),
  water('water'),
  grass('grass'),
  electric('electric'),
  ice('ice'),
  fighting('fighting'),
  poison('poison'),
  ground('ground'),
  flying('flying'),
  psychic('psychic'),
  bug('bug'),
  rock('rock'),
  ghost('ghost'),
  dragon('dragon'),
  dark('dark'),
  steel('steel'),
  fairy('fairy');

  const PokemonType(this.apiName);
  final String apiName;

  static PokemonType? fromApiName(String name) {
    final normalized = name.toLowerCase();
    for (final type in PokemonType.values) {
      if (type.apiName == normalized) {
        return type;
      }
    }
    return null;
  }

  String get assetPath => '${AppAssets.elementsBase}$apiName.svg';

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
