import 'package:pokedex_app/core/firebase/firebase_bootstrap.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/features/legal/domain/repositories/legal_documents_repository.dart';
import 'package:pokedex_app/features/legal/presentation/providers/legal_document_provider.dart';
import 'package:riverpod/misc.dart';

List<Override> legalRepositoryOverrides(
  LegalDocumentsRepository repository,
) {
  return [
    firebaseBootstrapProvider.overrideWithValue(
      const FirebaseBootstrapResult(isAvailable: false),
    ),
    legalDocumentsRepositoryProvider.overrideWithValue(repository),
  ];
}
