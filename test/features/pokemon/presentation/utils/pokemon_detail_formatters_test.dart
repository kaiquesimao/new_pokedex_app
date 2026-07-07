import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/features/pokemon/presentation/utils/pokemon_detail_formatters.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

import '../../../../helpers/l10n_test_helper.dart';

void main() {
  test('decimal respects locale', () {
    expect(PokemonDetailFormatters.decimal(6.9, AppLocale.pt), '6,9');
    expect(PokemonDetailFormatters.decimal(6.9, AppLocale.en), '6.9');
    expect(PokemonDetailFormatters.decimal(87.5, AppLocale.pt), '87,5');
  });

  testWidgets('statLabel maps api names to display labels', (tester) async {
    await pumpLocalizedApp(tester, child: const SizedBox());
    final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)));

    expect(PokemonDetailFormatters.statLabel(l10n, 'hp'), 'HP');
    expect(
      PokemonDetailFormatters.statLabel(l10n, 'special-attack'),
      'Atq. Esp.',
    );
    expect(PokemonDetailFormatters.statLabel(l10n, 'speed'), 'Velocidade');
  });

  testWidgets('genderLabel handles common gender rates', (tester) async {
    await pumpLocalizedApp(tester, child: const SizedBox());
    final l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)));

    expect(
      PokemonDetailFormatters.genderLabel(l10n, -1, AppLocale.pt),
      'Sem gênero',
    );
    expect(
      PokemonDetailFormatters.genderLabel(l10n, 0, AppLocale.pt),
      'Somente macho',
    );
    expect(
      PokemonDetailFormatters.genderLabel(l10n, 8, AppLocale.pt),
      'Somente fêmea',
    );
    expect(
      PokemonDetailFormatters.genderLabel(l10n, 254, AppLocale.pt),
      'Somente fêmea',
    );
    expect(
      PokemonDetailFormatters.genderLabel(l10n, 1, AppLocale.pt),
      '12,5% fêmea',
    );
    expect(PokemonDetailFormatters.femalePercent(1), 12.5);
    expect(PokemonDetailFormatters.malePercent(1), 87.5);
  });
}
