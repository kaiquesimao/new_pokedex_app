import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/pokemon/presentation/utils/pokemon_detail_formatters.dart';

void main() {
  test('decimal uses comma as decimal separator', () {
    expect(PokemonDetailFormatters.decimal(6.9), '6,9');
    expect(PokemonDetailFormatters.decimal(87.5), '87,5');
  });

  test('statLabel maps api names to display labels', () {
    expect(PokemonDetailFormatters.statLabel('hp'), 'HP');
    expect(PokemonDetailFormatters.statLabel('special-attack'), 'Atq. Esp.');
    expect(PokemonDetailFormatters.statLabel('speed'), 'Velocidade');
  });

  test('genderLabel handles common gender rates', () {
    expect(PokemonDetailFormatters.genderLabel(-1), 'Sem gênero');
    expect(PokemonDetailFormatters.genderLabel(0), 'Somente macho');
    expect(PokemonDetailFormatters.genderLabel(254), 'Somente fêmea');
  });

  test('abilityLabel formats hidden abilities', () {
    expect(
      PokemonDetailFormatters.abilityLabel('overgrow', isHidden: false),
      'Overgrow',
    );
    expect(
      PokemonDetailFormatters.abilityLabel('chlorophyll', isHidden: true),
      'Chlorophyll (oculta)',
    );
  });
}
