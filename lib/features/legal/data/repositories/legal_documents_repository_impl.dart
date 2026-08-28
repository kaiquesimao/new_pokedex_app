import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/features/legal/data/datasources/legal_documents_firestore_datasource.dart';
import 'package:pokedex_app/features/legal/data/datasources/legal_documents_local_datasource.dart';
import 'package:pokedex_app/features/legal/domain/entities/legal_document_content.dart';
import 'package:pokedex_app/features/legal/domain/repositories/legal_documents_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firestore-first legal documents with SharedPreferences + asset fallback.
class LegalDocumentsRepositoryImpl implements LegalDocumentsRepository {
  new({
    required this._local,
    required this._connectivity,
    required this._prefs,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore == null
           ? null
           : LegalDocumentsFirestoreDataSource(firestore: firestore);

  final LegalDocumentsLocalDataSource _local;
  final LegalDocumentsFirestoreDataSource? _firestore;
  final ConnectivityService _connectivity;
  final SharedPreferences _prefs;

  final Map<String, LegalDocumentContent> _memoryCache = {};

  static String _cacheKey(String documentId) => 'legal_doc_cache_$documentId';

  @override
  Future<LegalDocumentContent> getDocument({
    required LegalDocument document,
    required AppLocale locale,
  }) async {
    final documentId = legalDocumentId(document, locale);

    final cached = _memoryCache[documentId];
    if (cached != null) {
      return cached;
    }

    if (_firestore != null && _connectivity.isOnline) {
      try {
        final remote = await _firestore.fetchById(documentId);
        if (remote != null) {
          await _persistCache(documentId, remote);
          final resolved = remote.copyWith(source: LegalDocumentSource.firestore);
          _memoryCache[documentId] = resolved;
          return resolved;
        }
      } on Object catch (_) {
        // Fall through to cache/assets.
      }
    }

    final stored = _readPersistedCache(documentId);
    if (stored != null) {
      final resolved = stored.copyWith(source: LegalDocumentSource.cache);
      _memoryCache[documentId] = resolved;
      return resolved;
    }

    final asset = await _local.loadFromAsset(
      document: document,
      locale: locale,
    );
    _memoryCache[documentId] = asset;
    return asset;
  }

  LegalDocumentContent? _readPersistedCache(String documentId) {
    final raw = _prefs.getString(_cacheKey(documentId));
    if (raw == null) return null;

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final markdown = json['markdown'] as String?;
      if (markdown == null || markdown.isEmpty) return null;

      return LegalDocumentContent(
        slug: json['slug'] as String? ?? '',
        locale: json['locale'] as String? ?? '',
        markdown: markdown,
        version: json['version'] as String? ?? '1',
        source: LegalDocumentSource.cache,
      );
    } on Object catch (_) {
      return null;
    }
  }

  Future<void> _persistCache(
    String documentId,
    LegalDocumentContent content,
  ) async {
    final payload = jsonEncode({
      'slug': content.slug,
      'locale': content.locale,
      'markdown': content.markdown,
      'version': content.version,
    });
    await _prefs.setString(_cacheKey(documentId), payload);
  }
}
