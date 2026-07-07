import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_chip.dart';
import 'package:pokedex_app/shared/widgets/pokemon_type_icon.dart';

import '../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('PokemonTypeChip shows selected state', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: const Scaffold(
        body: PokemonTypeChip(type: PokemonType.fire, selected: true),
      ),
    );

    expect(find.text('Fogo'), findsOneWidget);
    expect(find.byType(PokemonTypeIcon), findsOneWidget);
  });
}
