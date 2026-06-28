import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/utils/pokemon_formatters.dart';

void main() {
  test('displayNumber pads id and uses Nº prefix', () {
    expect(PokemonFormatters.displayNumber(1), 'Nº001');
    expect(PokemonFormatters.displayNumber(25), 'Nº025');
    expect(PokemonFormatters.displayNumber(150), 'Nº150');
  });
}
