/// Source of a legal document payload shown in the app.
enum LegalDocumentSource {
  firestore,
  cache,
  asset,
}

/// Markdown legal document resolved for a slug and locale.
class const LegalDocumentContent({
  required final String slug,
  required final String locale,
  required final String markdown,
  required final String version,
  final LegalDocumentSource source = LegalDocumentSource.asset,
  final DateTime? updatedAt,
}) {
  LegalDocumentContent copyWith({
    LegalDocumentSource? source,
  }) {
    return LegalDocumentContent(
      slug: slug,
      locale: locale,
      markdown: markdown,
      version: version,
      source: source ?? this.source,
      updatedAt: updatedAt,
    );
  }
}
