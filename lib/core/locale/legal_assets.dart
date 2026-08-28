import 'package:pokedex_app/core/locale/app_locale.dart';

enum LegalDocument { terms, privacy, accountDeletion }

extension LegalDocumentSlug on LegalDocument {
  String get slug => switch (this) {
    LegalDocument.terms => 'terms',
    LegalDocument.privacy => 'privacy',
    LegalDocument.accountDeletion => 'account_deletion',
  };
}

/// Firestore locale tag aligned with [AppLocale].
String legalFirestoreLocale(AppLocale locale) {
  return locale == AppLocale.pt ? 'pt_BR' : 'en';
}

/// Deterministic Firestore document id, e.g. `terms_pt_BR`.
String legalDocumentId(LegalDocument document, AppLocale locale) {
  return '${document.slug}_${legalFirestoreLocale(locale)}';
}

String legalAssetPath(AppLocale locale, {required LegalDocument document}) {
  final lang = locale == AppLocale.pt ? 'pt_br' : 'en';
  return 'assets/legal/${document.slug}_$lang.md';
}
