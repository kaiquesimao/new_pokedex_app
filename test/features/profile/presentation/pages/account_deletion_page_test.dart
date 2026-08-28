import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/features/profile/presentation/pages/account_deletion_page.dart';

import '../../../../helpers/fake_legal_documents_repository.dart';
import '../../../../helpers/l10n_test_helper.dart';
import '../../../../helpers/legal_test_overrides.dart';

void main() {
  testWidgets('account deletion page shows deletion instructions', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      child: const AccountDeletionPage(),
      overrides: legalRepositoryOverrides(
        FakeLegalDocumentsRepository({
          legalDocumentId(LegalDocument.accountDeletion, AppLocale.pt):
              '# Exclusão de conta e dados - PokeData\n\n'
              'Envie um e-mail para pokedata.app@gmail.com.',
        }),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exclusão de conta e dados'), findsOneWidget);
    expect(find.textContaining('PokeData'), findsOneWidget);
    expect(find.textContaining('pokedata.app@gmail.com'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
