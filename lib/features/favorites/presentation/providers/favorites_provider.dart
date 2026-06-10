import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/favorites/data/repositories/firestore_favorites_repository.dart';
import 'package:pokedex_app/features/favorites/data/repositories/local_favorites_repository.dart';
import 'package:pokedex_app/features/favorites/domain/repositories/favorites_repository.dart';

final _localFavoritesRepositoryProvider = Provider<LocalFavoritesRepository>((
  ref,
) {
  final repo = LocalFavoritesRepository(ref.watch(sharedPreferencesProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final local = ref.watch(_localFavoritesRepositoryProvider);
  final auth = ref.watch(authProvider);

  final userId = auth.uid ?? auth.email;
  if (auth.isAuthenticated && userId != null) {
    return FirestoreFavoritesRepository(userId: userId, localCache: local);
  }

  return local;
});

class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier(this._repository) : super({}) {
    _subscription = _repository.watchFavoriteIds().listen((ids) {
      state = ids;
    });
    unawaited(_load());
  }

  final FavoritesRepository _repository;
  StreamSubscription<Set<int>>? _subscription;

  Future<void> _load() async {
    state = await _repository.getFavoriteIds();
  }

  Future<void> toggle(int id) => _repository.toggleFavorite(id);

  bool isFavorite(int id) => state.contains(id);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((
  ref,
) {
  return FavoritesNotifier(ref.watch(favoritesRepositoryProvider));
});
