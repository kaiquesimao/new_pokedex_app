import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';

void main() {
  test('fromApiName maps grass to grass asset', () {
    final type = PokemonType.fromApiName('grass');
    expect(type, PokemonType.grass);
    expect(type!.assetPath, 'assets/images/elements/grass.svg');
  });

  test('fromApiName returns null for unknown type', () {
    expect(PokemonType.fromApiName('unknown'), isNull);
  });
}
