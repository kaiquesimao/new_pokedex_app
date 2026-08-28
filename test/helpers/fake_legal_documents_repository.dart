import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/features/legal/domain/entities/legal_document_content.dart';
import 'package:pokedex_app/features/legal/domain/repositories/legal_documents_repository.dart';

class FakeLegalDocumentsRepository(
  final Map<String, String> _markdownByDocumentId,
) implements LegalDocumentsRepository {
  @override
  Future<LegalDocumentContent> getDocument({
    required LegalDocument document,
    required AppLocale locale,
  }) async {
    final documentId = legalDocumentId(document, locale);
    final markdown = _markdownByDocumentId[documentId];
    if (markdown == null) {
      throw StateError('Missing fake legal document: $documentId');
    }

    return LegalDocumentContent(
      slug: document.slug,
      locale: legalFirestoreLocale(locale),
      markdown: markdown,
      version: 'test',
      source: LegalDocumentSource.firestore,
    );
  }
}
