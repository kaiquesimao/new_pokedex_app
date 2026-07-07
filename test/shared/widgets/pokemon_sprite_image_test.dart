import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
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
  testWidgets('PokemonSpriteImage applies DPR-aware memCache dimensions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _localizedApp(
        home: const Scaffold(
          body: PokemonSpriteImage(
            imageUrl: 'https://example.com/pokemon/1.png',
            height: 72,
            maxCachePixels: PokemonSpriteCachePresets.listRow,
          ),
        ),
      ),
    );

    final cachedImage = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );

    expect(cachedImage.memCacheWidth, 216);
    expect(cachedImage.memCacheHeight, 216);
    expect(cachedImage.filterQuality, FilterQuality.high);
    expect(cachedImage.progressIndicatorBuilder, isNotNull);
  });

  testWidgets('PokemonSpriteImage shows loading placeholder while fetching', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        home: const Scaffold(
          body: PokemonSpriteImage(
            imageUrl: 'https://example.com/pokemon/1.png',
            height: 72,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Loading Pokémon image'), findsOneWidget);
  });

  testWidgets('PokemonSpriteLoadingPlaceholder scales indicator with slot', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        home: const Scaffold(
          body: PokemonSpriteLoadingPlaceholder(width: 48, height: 48),
        ),
      ),
    );

    final indicator = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(Center),
        matching: find.byType(SizedBox).last,
      ),
    );

    expect(indicator.width, greaterThanOrEqualTo(16));
    expect(indicator.width, lessThanOrEqualTo(28));
  });

  testWidgets('PokemonSpriteImage wraps Hero when heroTag is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        home: const Scaffold(
          body: PokemonSpriteImage(
            imageUrl: 'https://example.com/pokemon/1.png',
            height: 72,
            heroTag: 'pokemon-sprite-1',
          ),
        ),
      ),
    );

    expect(find.byType(Hero), findsOneWidget);
  });
}
