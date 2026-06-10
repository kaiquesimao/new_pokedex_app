import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pokedex_app/features/favorites/data/repositories/local_favorites_repository.dart';
import 'package:pokedex_app/features/favorites/domain/repositories/favorites_repository.dart';

/// Firestore-backed favorites repository with offline-first local cache.
class FirestoreFavoritesRepository implements FavoritesRepository {
  FirestoreFavoritesRepository({
    required this.userId,
    required this.localCache,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance {
    unawaited(_syncOnLogin());
  }

  final String userId;
  final LocalFavoritesRepository localCache;
  final FirebaseFirestore _firestore;

  static const _collection = 'users';
  static const _subcollection = 'favorites';

  CollectionReference<Map<String, dynamic>> get _favoritesCollection =>
      _firestore.collection(_collection).doc(userId).collection(_subcollection);

  @override
  Future<Set<int>> getFavoriteIds() => localCache.getFavoriteIds();

  @override
  Future<bool> isFavorite(int pokemonId) => localCache.isFavorite(pokemonId);

  @override
  Future<void> toggleFavorite(int pokemonId) async {
    final wasFavorite = await localCache.isFavorite(pokemonId);
    await localCache.toggleFavorite(pokemonId);

    try {
      final doc = _favoritesCollection.doc(pokemonId.toString());
      if (wasFavorite) {
        await doc.delete();
      } else {
        await doc.set({
          'pokemonId': pokemonId,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // Offline: local cache already updated.
    }
  }

  @override
  Stream<Set<int>> watchFavoriteIds() async* {
    yield await localCache.getFavoriteIds();

    try {
      await for (final snapshot in _favoritesCollection.snapshots()) {
        final remoteIds = snapshot.docs
            .map(
              (doc) =>
                  int.tryParse(doc.id) ?? doc.data()['pokemonId'] as int?,
            )
            .whereType<int>()
            .toSet();

        final localIds = await localCache.getFavoriteIds();
        final merged = {...localIds, ...remoteIds};

        if (merged.length != localIds.length ||
            !merged.containsAll(localIds)) {
          await localCache.replaceAll(merged);
        }

        yield merged;
      }
    } catch (_) {
      yield* localCache.watchFavoriteIds();
    }
  }

  Future<void> _syncOnLogin() async {
    try {
      final snapshot = await _favoritesCollection.get();
      final remoteIds = snapshot.docs
          .map((doc) => int.tryParse(doc.id) ?? doc.data()['pokemonId'] as int?)
          .whereType<int>()
          .toSet();

      final localIds = await localCache.getFavoriteIds();
      final merged = {...localIds, ...remoteIds};

      await localCache.replaceAll(merged);

      final onlyLocal = localIds.difference(remoteIds);
      for (final pokemonId in onlyLocal) {
        await _favoritesCollection.doc(pokemonId.toString()).set({
          'pokemonId': pokemonId,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // Offline: keep local cache.
    }
  }

  String get firestorePath => '$_collection/$userId/$_subcollection';
}
