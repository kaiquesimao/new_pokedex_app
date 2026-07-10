import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/game_text_source.dart';
import 'package:pokedex_app/core/locale/resolved_game_text.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/localized_flavor_text_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/widgets/pokemon_detail_about_section.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import '../../../../helpers/l10n_test_helper.dart';

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

    await pumpLocalizedApp(
      tester,
      child: const Scaffold(
        body: SingleChildScrollView(
          child: PokemonDetailAboutSection(pokemon: pokemon),
        ),
      ),
    );

    expect(find.textContaining('87,5%'), findsOneWidget);
    expect(find.textContaining('12,5%'), findsOneWidget);

    final barSize = tester.getSize(find.byKey(const Key('gender_bar_track')));
    expect(barSize.height, 12);
    expect(barSize.width, greaterThan(100));
  });

  testWidgets('shows category genus instead of egg group', (tester) async {
    const pokemon = PokemonDetail(
      id: 25,
      name: 'pikachu',
      height: 4,
      weight: 60,
      types: [PokemonType.electric],
      stats: [PokemonStat(name: 'hp', baseStat: 35)],
      abilities: [PokemonAbility(name: 'static', isHidden: false)],
      genderRate: 4,
      eggGroups: ['field'],
      category: 'Pokémon Rato',
    );

    await pumpLocalizedApp(
      tester,
      child: const Scaffold(
        body: SingleChildScrollView(
          child: PokemonDetailAboutSection(pokemon: pokemon),
        ),
      ),
    );

    expect(find.text('Pokémon Rato'), findsOneWidget);
    expect(find.text('field'), findsNothing);
  });

  testWidgets('hides English flavor text while MT is pending', (
    tester,
  ) async {
    const pokemon = PokemonDetail(
      id: 25,
      name: 'pikachu',
      height: 4,
      weight: 60,
      types: [PokemonType.electric],
      stats: [PokemonStat(name: 'hp', baseStat: 35)],
      abilities: [PokemonAbility(name: 'static', isHidden: false)],
      genderRate: 4,
      eggGroups: ['field'],
      flavorText: 'When several electric Pokémon gather, a thunderstorm forms.',
    );
    final completer = Completer<ResolvedGameText?>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileSettingsProvider.overrideWithBuild(
            (ref, notifier) => ProfileSettings(appLanguage: AppLocale.pt.tag),
          ),
          localizedFlavorTextProvider.overrideWith((ref, input) {
            return completer.future;
          }),
        ],
        child: MaterialApp(
          locale: AppLocale.pt.materialLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: PokemonDetailAboutSection(
                pokemon: pokemon,
                flavorTextEntries: [
                  {
                    'flavor_text': 'When several electric Pokémon gather, '
                        'a thunderstorm forms.',
                    'language': {'name': 'en'},
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('thunderstorm'), findsNothing);

    completer.complete(
      const ResolvedGameText(
        text: 'Quando vários Pokémon elétricos se reúnem, formam-se tempestades.',
        source: GameTextSource.machineTranslated,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.textContaining('tempestades'),
      findsOneWidget,
    );
  });

  testWidgets('category and ability values wrap instead of ellipsizing', (
    tester,
  ) async {
    const longCategory = 'Super Extra Long Pokémon Category Name';
    const longAbility = 'super-extra-long-hidden-ability-name';
    const pokemon = PokemonDetail(
      id: 1,
      name: 'bulbasaur',
      height: 7,
      weight: 69,
      types: [PokemonType.grass],
      stats: [PokemonStat(name: 'hp', baseStat: 45)],
      abilities: [
        PokemonAbility(name: longAbility, isHidden: false),
      ],
      genderRate: 1,
      eggGroups: ['monster'],
      category: longCategory,
    );

    await pumpLocalizedApp(
      tester,
      child: const Scaffold(
        body: SingleChildScrollView(
          child: PokemonDetailAboutSection(pokemon: pokemon),
        ),
      ),
    );

    expect(find.text(longCategory), findsOneWidget);
    expect(find.text(longAbility), findsOneWidget);
    expect(find.textContaining('…'), findsNothing);
  });
}
