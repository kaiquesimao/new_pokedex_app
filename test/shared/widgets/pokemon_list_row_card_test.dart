import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_card.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';

import '../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('PokemonListRowCard renders one type', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: const Scaffold(
        body: PokemonListRowCard(
          number: 4,
          name: 'Charmander',
          types: [PokemonType.fire],
        ),
      ),
    );

    expect(find.text('Nº004'), findsOneWidget);
    expect(find.text('Charmander'), findsOneWidget);
    expect(find.text('Fogo'), findsOneWidget);
    expect(find.byType(PokemonTypeChip), findsOneWidget);
  });

  testWidgets('PokemonListRowCard renders two types', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: const Scaffold(
        body: PokemonListRowCard(
          number: 1,
          name: 'Bulbasaur',
          types: [PokemonType.grass, PokemonType.poison],
        ),
      ),
    );

    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Grama'), findsOneWidget);
    expect(find.text('Veneno'), findsOneWidget);
    expect(find.byType(PokemonTypeChip), findsNWidgets(2));
  });

  testWidgets('PokemonListRowCard avoids overflow on narrow screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpLocalizedApp(
      tester,
      child: const Scaffold(
        body: PokemonListRowCard(
          number: 26,
          name: 'Raichu',
          types: [PokemonType.electric, PokemonType.psychic],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Elétrico'), findsOneWidget);
    expect(find.text('Psíquico'), findsOneWidget);
  });
}
