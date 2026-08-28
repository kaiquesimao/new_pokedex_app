import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/features/profile/presentation/pages/terms_of_use_page.dart';

import '../../../../helpers/fake_legal_documents_repository.dart';
import '../../../../helpers/l10n_test_helper.dart';
import '../../../../helpers/legal_test_overrides.dart';

void main() {
  testWidgets('terms page shows disclaimer and scrollable sections', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      child: const TermsOfUsePage(),
      overrides: legalRepositoryOverrides(
        FakeLegalDocumentsRepository({
          legalDocumentId(LegalDocument.terms, AppLocale.pt):
              '# Termos de Uso - PokeData\n\n'
              'O PokeData não é desenvolvido, endossado ou afiliado.',
        }),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Termos de uso'), findsOneWidget);
    expect(
      find.textContaining('não é desenvolvido, endossado ou afiliado'),
      findsOneWidget,
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
