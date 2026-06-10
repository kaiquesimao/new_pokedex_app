import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/type_weakness_utils.dart';

void main() {
  test('fire weaknesses are water, ground and rock', () {
    final weaknesses = weaknessesForTypes([PokemonType.fire]);

    expect(weaknesses, {
      PokemonType.water,
      PokemonType.ground,
      PokemonType.rock,
    });
  });

  test('dual types combine weaknesses', () {
    final weaknesses = weaknessesForTypes([
      PokemonType.grass,
      PokemonType.poison,
    ]);

    expect(weaknesses, contains(PokemonType.fire));
    expect(weaknesses, contains(PokemonType.psychic));
    expect(weaknesses, contains(PokemonType.ground));
  });
}
