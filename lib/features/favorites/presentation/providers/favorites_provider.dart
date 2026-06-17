import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/favorites/data/repositories/firestore_favorites_repository.dart';
import 'package:pokedex_app/features/favorites/data/repositories/local_favorites_repository.dart';
import 'package:pokedex_app/features/favorites/data/repositories/unauthenticated_favorites_repository.dart';
import 'package:pokedex_app/features/favorites/domain/repositories/favorites_repository.dart';

final localFavoritesRepositoryProvider = Provider<LocalFavoritesRepository>((
  ref,
) {
  final repo = LocalFavoritesRepository(ref.watch(sharedPreferencesProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final auth = ref.watch(authProvider);

  final userId = auth.uid ?? auth.email;
  if (!auth.isAuthenticated || userId == null) {
    return const UnauthenticatedFavoritesRepository();
  }

  final local = ref.watch(localFavoritesRepositoryProvider);
  return FirestoreFavoritesRepository(
    userId: userId,
    localCache: local,
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

class FavoritesNotifier extends Notifier<Set<int>> {
  StreamSubscription<Set<int>>? _subscription;

  @override
  Set<int> build() {
    ref
      ..onDispose(() {
        unawaited(_subscription?.cancel());
      })
      ..listen(authProvider, (previous, next) {
        if (previous?.uid == next.uid &&
            previous?.isAuthenticated == next.isAuthenticated) {
          return;
        }
        unawaited(_attachRepository());
      });

    // Defer repository wiring so auth-driven provider rebuilds do not run
    // while a widget (e.g. PokemonListPage) is still building.
    unawaited(Future.microtask(_attachRepository));

    return {};
  }

  Future<void> _attachRepository() async {
    await _subscription?.cancel();
    final repository = ref.read(favoritesRepositoryProvider);
    _subscription = repository.watchFavoriteIds().listen((ids) {
      state = ids;
    });
    state = await repository.getFavoriteIds();
  }

  FavoritesRepository get _repository => ref.read(favoritesRepositoryProvider);

  Future<void> toggle(int id) => _repository.toggleFavorite(id);

  bool isFavorite(int id) => state.contains(id);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<int>>(
  FavoritesNotifier.new,
);
