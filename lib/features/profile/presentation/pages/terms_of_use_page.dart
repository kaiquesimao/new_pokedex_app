import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/legal_document_view.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class const TermsOfUsePage({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTermsLabel)),
      body: SafePageBody.belowAppBar(
        child: LegalDocumentView(
          document: LegalDocument.terms,
          loadErrorMessage: l10n.legalLoadTermsError,
        ),
      ),
    );
  }
}
