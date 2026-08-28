import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokedex_app/features/legal/domain/entities/legal_document_content.dart';

/// Reads published legal documents from Firestore.
class LegalDocumentsFirestoreDataSource({
  required final FirebaseFirestore _firestore,
}) {
  static const collection = 'legal_documents';

  Future<LegalDocumentContent?> fetchById(String documentId) async {
    final snapshot = await _firestore.collection(collection).doc(documentId).get();
    if (!snapshot.exists) return null;

    final data = snapshot.data();
    if (data == null) return null;
    if (data['published'] != true) return null;

    final markdown = data['markdown'] as String? ?? data['body'] as String?;
    if (markdown == null || markdown.isEmpty) return null;

    final updatedAt = data['updatedAt'];
    return LegalDocumentContent(
      slug: data['slug'] as String? ?? '',
      locale: data['locale'] as String? ?? '',
      markdown: markdown,
      version: data['version'] as String? ?? '1',
      source: LegalDocumentSource.firestore,
      updatedAt: switch (updatedAt) {
        Timestamp(:final seconds) => DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000,
          isUtc: true,
        ).toLocal(),
        _ => null,
      },
    );
  }
}
