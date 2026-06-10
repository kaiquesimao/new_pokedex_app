import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/theme/app_theme.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';

void main() {
  testWidgets('PokemonTypeChip shows selected state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: PokemonTypeChip(type: PokemonType.fire, selected: true),
        ),
      ),
    );

    expect(find.text('Fogo'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
