import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/utils/image_cache_dimensions.dart';
import 'package:pokedex_app/shared/widgets/legal_document_skeleton.dart';
import 'package:pokedex_app/shared/widgets/pokemon_detail_skeleton.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_skeleton.dart';

/// Shimmer animates forever; avoid [WidgetTester.pumpAndSettle].
Future<void> _pumpSkeleton(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: child));
  await tester.pump();
}

void main() {
  testWidgets('PokemonListRowSkeleton matches list row height', (tester) async {
    await _pumpSkeleton(
      tester,
      const Scaffold(
        body: Center(child: PokemonListRowSkeleton()),
      ),
    );

    final size = tester.getSize(find.byType(PokemonListRowSkeleton));
    expect(size.height, PokemonSpriteLayoutSizes.listRowHeight);
  });

  testWidgets(
    'PokemonDetailSkeleton has header and three section blocks',
    (tester) async {
      await _pumpSkeleton(
        tester,
        const Scaffold(
          body: SizedBox(
            height: 900,
            child: PokemonDetailSkeleton(),
          ),
        ),
      );

      expect(
        tester.getSize(find.byKey(PokemonDetailSkeleton.headerKey)).height,
        PokemonSpriteLayoutSizes.detailHeaderHeight,
      );
      expect(
        find.byKey(PokemonDetailSkeleton.sectionKey(0)),
        findsOneWidget,
      );
      expect(
        find.byKey(PokemonDetailSkeleton.sectionKey(1)),
        findsOneWidget,
      );
      expect(
        find.byKey(PokemonDetailSkeleton.sectionKey(2)),
        findsOneWidget,
      );
    },
  );

  testWidgets('LegalDocumentSkeleton uses document padding', (tester) async {
    await _pumpSkeleton(
      tester,
      const Scaffold(body: LegalDocumentSkeleton()),
    );

    final padding = tester.widget<Padding>(
      find
          .descendant(
            of: find.byType(LegalDocumentSkeleton),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(padding.padding, LegalDocumentSkeleton.contentPadding);
  });
}
