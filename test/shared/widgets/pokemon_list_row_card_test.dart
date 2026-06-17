import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/theme/app_theme.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_card.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';

void main() {
  testWidgets('PokemonListRowCard renders one type', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: PokemonListRowCard(
            number: 4,
            name: 'Charmander',
            types: [PokemonType.fire],
          ),
        ),
      ),
    );

    expect(find.text('#004'), findsOneWidget);
    expect(find.text('Charmander'), findsOneWidget);
    expect(find.byType(PokemonTypeChip), findsOneWidget);
  });

  testWidgets('PokemonListRowCard renders two types', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: PokemonListRowCard(
            number: 1,
            name: 'Bulbasaur',
            types: [PokemonType.grass, PokemonType.poison],
          ),
        ),
      ),
    );

    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.byType(PokemonTypeChip), findsNWidgets(2));
  });
}
