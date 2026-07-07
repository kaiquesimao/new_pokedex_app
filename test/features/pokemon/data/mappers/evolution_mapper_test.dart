import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/pokemon/data/mappers/evolution_mapper.dart';
import 'package:pokedex_app/features/pokemon/data/models/evolution_models.dart';
import 'package:pokedex_app/l10n/generated/app_localizations_pt.dart';

void main() {
  test('toNode maps bulbasaur evolution chain correctly', () async {
    final jsonString = await File(
      'test/fixtures/bulbasaur_evolution_chain.json',
    ).readAsString();
    final response = EvolutionChainResponse.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );

    final root = EvolutionMapper.toNode(response.chain);

    expect(root.speciesName, 'bulbasaur');
    expect(root.speciesId, 1);
    expect(root.evolvesTo, hasLength(1));

    final ivysaur = root.evolvesTo.first;
    expect(ivysaur.speciesName, 'ivysaur');
    expect(ivysaur.trigger?.minLevel, 16);
    expect(ivysaur.trigger?.displayLabel(AppLocalizationsPt()), 'Nível 16');

    final venusaur = ivysaur.evolvesTo.first;
    expect(venusaur.speciesName, 'venusaur');
    expect(venusaur.trigger?.minLevel, 32);
    expect(venusaur.evolvesTo, isEmpty);
  });
}
