import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/presentation/widgets/pokemon_detail_about_section.dart';

void main() {
  testWidgets('gender bar track renders with visible size', (tester) async {
    const pokemon = PokemonDetail(
      id: 1,
      name: 'bulbasaur',
      height: 7,
      weight: 69,
      types: [PokemonType.grass],
      stats: [PokemonStat(name: 'hp', baseStat: 45)],
      abilities: [PokemonAbility(name: 'overgrow', isHidden: false)],
      genderRate: 1,
      eggGroups: ['monster'],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PokemonDetailAboutSection(pokemon: pokemon),
          ),
        ),
      ),
    );

    expect(find.textContaining('87,5%'), findsOneWidget);
    expect(find.textContaining('12,5%'), findsOneWidget);

    final barSize = tester.getSize(find.byKey(const Key('gender_bar_track')));
    expect(barSize.height, 12);
    expect(barSize.width, greaterThan(100));
  });
}
