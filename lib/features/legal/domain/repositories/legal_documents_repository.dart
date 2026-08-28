import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/features/legal/domain/entities/legal_document_content.dart';

abstract class LegalDocumentsRepository {
  Future<LegalDocumentContent> getDocument({
    required LegalDocument document,
    required AppLocale locale,
  });
}
