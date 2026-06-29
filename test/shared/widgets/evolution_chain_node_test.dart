import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';
import 'package:pokedex_app/shared/widgets/evolution_chain_node.dart';

void main() {
  testWidgets('evolution card shows name, number and level connector', (
    tester,
  ) async {
    const root = EvolutionChainNode(
      speciesId: 1,
      speciesName: 'bulbasaur',
      types: [PokemonType.grass, PokemonType.poison],
      evolvesTo: [
        EvolutionChainNode(
          speciesId: 2,
          speciesName: 'ivysaur',
          types: [PokemonType.grass, PokemonType.poison],
          trigger: EvolutionTriggerInfo(minLevel: 16),
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: EvolutionChainTree(
              root: root,
              currentPokemonId: 1,
              embedded: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Nº001'), findsOneWidget);
    expect(find.text('Nível 16'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
  });
}
