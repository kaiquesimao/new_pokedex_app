/// Source of a legal document payload shown in the app.
enum LegalDocumentSource {
  firestore,
  cache,
  asset,
}

/// Markdown legal document resolved for a slug and locale.
class LegalDocumentContent {
  const LegalDocumentContent({
    required this.slug,
    required this.locale,
    required this.markdown,
    required this.version,
    this.source = LegalDocumentSource.asset,
    this.updatedAt,
  });

  final String slug;
  final String locale;
  final String markdown;
  final String version;
  final LegalDocumentSource source;
  final DateTime? updatedAt;

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
