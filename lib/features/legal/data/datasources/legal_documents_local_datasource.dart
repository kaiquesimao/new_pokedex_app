import 'package:flutter/services.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/features/legal/domain/entities/legal_document_content.dart';

/// Loads bundled Markdown assets used as emergency fallback.
class LegalDocumentsLocalDataSource {
  new({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const bundledVersion = '2026-07-06';

  Future<LegalDocumentContent> loadFromAsset({
    required LegalDocument document,
    required AppLocale locale,
  }) async {
    final assetPath = legalAssetPath(locale, document: document);
    final markdown = await _bundle.loadString(assetPath);

    return LegalDocumentContent(
      slug: document.slug,
      locale: legalFirestoreLocale(locale),
      markdown: markdown,
      version: bundledVersion,
    );
  }
}
