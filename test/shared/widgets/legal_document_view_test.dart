import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/features/legal/domain/entities/legal_document_content.dart';
import 'package:pokedex_app/features/legal/presentation/providers/legal_document_provider.dart';
import 'package:pokedex_app/shared/widgets/legal_document_view.dart';

import '../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('legal markdown selects text without SelectableText', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      child: const LegalDocumentView(
        document: LegalDocument.terms,
        loadErrorMessage: 'failed',
      ),
      overrides: [
        legalDocumentProvider.overrideWith(
          (ref, input) async => LegalDocumentContent(
            slug: input.document.slug,
            locale: input.locale.tag,
            markdown: 'Paragraph that can be selected.',
            version: '1',
          ),
        ),
      ],
    );

    expect(find.byType(SelectionArea), findsOneWidget);
    expect(find.byType(flutter_material.SelectableText), findsNothing);
    expect(
      find.textContaining('Paragraph that can be selected'),
      findsOneWidget,
    );

    await tester.longPress(
      find.textContaining('Paragraph that can be selected'),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
