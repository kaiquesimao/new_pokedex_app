import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_hero_tags.dart';
import 'package:pokedex_app/features/shell/presentation/widgets/shell_tab_scope.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';

Widget _localizedApp({required Widget home}) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}

void main() {
  testWidgets('listSpriteHeroTag is null when shell tab is inactive', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        home: ShellTabScope(
          currentIndex: 1,
          child: Builder(
            builder: (context) {
              final tag = PokemonHeroTags.listSpriteHeroTag(
                context,
                pokemonId: 2,
                heroShellTabIndex: 0,
              );
              expect(tag, isNull);

              return PokemonSpriteImage(
                imageUrl: 'https://example.com/2.png',
                height: 72,
                heroTag: tag,
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(Hero), findsNothing);
  });

  testWidgets('listSpriteHeroTag is set when shell tab is active', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        home: ShellTabScope(
          currentIndex: 0,
          child: Builder(
            builder: (context) {
              final tag = PokemonHeroTags.listSpriteHeroTag(
                context,
                pokemonId: 2,
                heroShellTabIndex: 0,
              );
              expect(tag, 'pokemon_sprite_2');

              return PokemonSpriteImage(
                imageUrl: 'https://example.com/2.png',
                height: 72,
                heroTag: tag,
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(Hero), findsOneWidget);
  });
}
