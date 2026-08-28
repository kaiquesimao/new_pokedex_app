import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/features/legal/data/datasources/legal_documents_local_datasource.dart';
import 'package:pokedex_app/features/legal/data/repositories/legal_documents_repository_impl.dart';
import 'package:pokedex_app/features/legal/domain/entities/legal_document_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OfflineConnectivity extends ConnectivityService {
  @override
  bool get isOnline => false;
}

class _TestAssetBundle(final Map<String, String> files)
    extends CachingAssetBundle {

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = files[key];
    if (value == null) {
      throw FlutterError('Asset not found in test bundle: $key');
    }
    return value;
  }

  @override
  Future<ByteData> load(String key) async {
    final value = files[key];
    if (value == null) {
      throw FlutterError('Asset not found in test bundle: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.view(bytes.buffer);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LegalDocumentsRepositoryImpl', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('falls back to bundled asset when offline and cache empty', () async {
      const markdown = '# Terms\n\nOffline fallback.';
      final repository = LegalDocumentsRepositoryImpl(
        local: LegalDocumentsLocalDataSource(
          bundle: _TestAssetBundle({
            legalAssetPath(AppLocale.pt, document: LegalDocument.terms):
                markdown,
          }),
        ),
        connectivity: _OfflineConnectivity(),
        prefs: prefs,
      );

      final content = await repository.getDocument(
        document: LegalDocument.terms,
        locale: AppLocale.pt,
      );

      expect(content.markdown, markdown);
      expect(content.source, LegalDocumentSource.asset);
    });

    test('returns persisted cache when offline after prior fetch', () async {
      const markdown = '# Privacy cached copy.';
      final documentId = legalDocumentId(
        LegalDocument.privacy,
        AppLocale.pt,
      );
      await prefs.setString(
        'legal_doc_cache_$documentId',
        jsonEncode({
          'slug': 'privacy',
          'locale': 'pt_BR',
          'markdown': markdown,
          'version': '2',
        }),
      );

      final repository = LegalDocumentsRepositoryImpl(
        local: LegalDocumentsLocalDataSource(
          bundle: _TestAssetBundle({}),
        ),
        connectivity: _OfflineConnectivity(),
        prefs: prefs,
      );

      final content = await repository.getDocument(
        document: LegalDocument.privacy,
        locale: AppLocale.pt,
      );

      expect(content.markdown, markdown);
      expect(content.source, LegalDocumentSource.cache);
    });
  });
}
