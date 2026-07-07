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
}
