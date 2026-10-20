import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/constants/pokemon_hero_tags.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/presentation/pokemon_detail_preview.dart';
import 'package:pokedex_app/features/pokemon/presentation/widgets/pokemon_detail_header.dart';
import 'package:pokedex_app/shared/widgets/pokemon_detail_skeleton.dart';

void main() {
  group('PokemonDetailPreview.fromExtra', () {
    test('keeps a matching preview and drops anything else', () {
      const preview = PokemonDetailPreview(
        id: 1,
        displayName: 'Bulbasaur',
        spriteUrl: 'https://example.com/1.png',
        types: [PokemonType.grass],
      );

      expect(PokemonDetailPreview.fromExtra(preview, 1), same(preview));
      expect(PokemonDetailPreview.fromExtra(preview, 2), isNull);
      expect(PokemonDetailPreview.fromExtra('bulbasaur', 1), isNull);
      expect(
        PokemonDetailPreview.fromExtra(
          const PokemonDetailPreview(id: 1, displayName: '  '),
          1,
        ),
        isNull,
      );
    });
  });

  group('showLoadedPokemonDetail', () {
    test('keeps the preview hero until the transition settles', () {
      expect(
        showLoadedPokemonDetail(
          hasBundle: true,
          libraryReady: true,
          hasPreview: true,
          transitionSettled: false,
        ),
        isFalse,
      );
      expect(
        showLoadedPokemonDetail(
          hasBundle: true,
          libraryReady: true,
          hasPreview: true,
          transitionSettled: true,
        ),
        isTrue,
      );
    });

    test('shows the loaded page immediately when there is no preview', () {
      expect(
        showLoadedPokemonDetail(
          hasBundle: true,
          libraryReady: true,
          hasPreview: false,
          transitionSettled: false,
        ),
        isTrue,
      );
      expect(
        showLoadedPokemonDetail(
          hasBundle: false,
          libraryReady: true,
          hasPreview: false,
          transitionSettled: true,
        ),
        isFalse,
      );
    });
  });

  testWidgets('preview sprite uses the same hero tag as the list card', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PokemonDetailPreviewSprite(pokemonId: 1),
        ),
      ),
    );

    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, PokemonHeroTags.sprite(1));
  });

  testWidgets('identity card shows the known name above section placeholders', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              PokemonDetailIdentityCard(
                displayName: 'Bulbasaur',
                pokemonId: 1,
                types: [],
              ),
              PokemonDetailSectionBlocks(),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Nº001'), findsOneWidget);
    expect(find.byKey(PokemonDetailSkeleton.sectionKey(0)), findsOneWidget);
    expect(find.byKey(PokemonDetailSkeleton.sectionKey(2)), findsOneWidget);
  });
}
