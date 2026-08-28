import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/features/legal/data/datasources/legal_documents_local_datasource.dart';
import 'package:pokedex_app/features/legal/data/repositories/legal_documents_repository_impl.dart';
import 'package:pokedex_app/features/legal/domain/entities/legal_document_content.dart';
import 'package:pokedex_app/features/legal/domain/repositories/legal_documents_repository.dart';
import 'package:riverpod/misc.dart';

typedef LegalDocumentInput = ({
  LegalDocument document,
  AppLocale locale,
});

final legalDocumentsRepositoryProvider = Provider<LegalDocumentsRepository>((
  ref,
) {
  final firebase = ref.watch(firebaseBootstrapProvider);
  return LegalDocumentsRepositoryImpl(
    local: LegalDocumentsLocalDataSource(),
    connectivity: ref.watch(connectivityServiceProvider),
    prefs: ref.watch(sharedPreferencesProvider),
    firestore: firebase.isAvailable ? FirebaseFirestore.instance : null,
  );
});

final FutureProviderFamily<LegalDocumentContent, LegalDocumentInput>
legalDocumentProvider = FutureProvider.family<LegalDocumentContent,
    LegalDocumentInput>((ref, input) {
      final repository = ref.watch(legalDocumentsRepositoryProvider);
      return repository.getDocument(
        document: input.document,
        locale: input.locale,
      );
    });
