import 'package:pokedex_app/core/locale/app_locale.dart';

enum LegalDocument { terms, privacy, accountDeletion }

String legalAssetPath(AppLocale locale, {required LegalDocument document}) {
  final lang = locale == AppLocale.pt ? 'pt_br' : 'en';
  final name = switch (document) {
    LegalDocument.terms => 'terms',
    LegalDocument.privacy => 'privacy',
    LegalDocument.accountDeletion => 'account_deletion',
  };
  return 'assets/legal/${name}_$lang.md';
}
