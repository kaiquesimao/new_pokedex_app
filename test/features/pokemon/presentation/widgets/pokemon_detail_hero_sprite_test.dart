import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_sprite_variant.dart';
import 'package:pokedex_app/features/pokemon/domain/utils/pokemon_sprite_variant_labels.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_detail_sprite_variants_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/widgets/pokemon_detail_sprite_carousel.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:pokedex_app/l10n/app_localization_delegates.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

const _pokemon = PokemonDetail(
  id: 6,
  name: 'charizard',
  height: 17,
  weight: 905,
  types: [PokemonType.fire, PokemonType.flying],
  stats: [],
  abilities: [],
  spriteUrl: 'https://example.com/6.png',
);

void main() {
  testWidgets('shows mini loading while extra forms are fetched', (
    tester,
  ) async {
    final completer = Completer<List<PokemonSpriteVariant>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileSettingsProvider.overrideWithBuild(
            (ref, notifier) => ProfileSettings(appLanguage: AppLocale.pt.tag),
          ),
          pokemonDetailSpriteVariantsProvider.overrideWith(
            (ref, id) => completer.future,
          ),
        ],
        child: MaterialApp(
          locale: AppLocale.pt.materialLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: appLocalizationDelegates,
          home: const Scaffold(
            body: PokemonDetailHeroSprite(
              pokemonId: 6,
              pokemon: _pokemon,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Carregando formas'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.byType(PokemonDetailSpriteCarousel), findsNothing);

    completer.complete(const [
      PokemonSpriteVariant(
        imageUrl: 'https://example.com/6.png',
        pokemonId: 6,
        labelKey: PokemonSpriteVariantLabelKeys.normal,
      ),
      PokemonSpriteVariant(
        imageUrl: 'https://example.com/6-shiny.png',
        pokemonId: 6,
        labelKey: PokemonSpriteVariantLabelKeys.shiny,
        isShiny: true,
      ),
    ]);
    await tester.pump();

    expect(find.bySemanticsLabel('Carregando formas'), findsNothing);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.byType(PokemonDetailSpriteCarousel), findsOneWidget);
  });
}
