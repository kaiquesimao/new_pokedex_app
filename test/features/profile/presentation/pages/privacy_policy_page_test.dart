import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/features/profile/presentation/pages/privacy_policy_page.dart';

import '../../../../helpers/fake_legal_documents_repository.dart';
import '../../../../helpers/l10n_test_helper.dart';
import '../../../../helpers/legal_test_overrides.dart';

void main() {
  testWidgets('privacy page shows policy content', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: const PrivacyPolicyPage(),
      overrides: legalRepositoryOverrides(
        FakeLegalDocumentsRepository({
          legalDocumentId(LegalDocument.privacy, AppLocale.pt):
              '# Política de Privacidade - PokeData\n\n'
              'Texto de exemplo da política.',
        }),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Política de privacidade'), findsOneWidget);
    expect(
      find.textContaining('Política de Privacidade - PokeData'),
      findsOneWidget,
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
