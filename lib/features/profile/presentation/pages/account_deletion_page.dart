import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/app_locale_provider.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/legal_document_view.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class AccountDeletionPage extends ConsumerWidget {
  const AccountDeletionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(appLocaleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileAccountDeletionLabel)),
      body: SafePageBody.belowAppBar(
        child: LegalDocumentView(
          assetPath: legalAssetPath(
            locale,
            document: LegalDocument.accountDeletion,
          ),
          loadErrorMessage: l10n.legalLoadAccountDeletionError,
        ),
      ),
    );
  }
}
