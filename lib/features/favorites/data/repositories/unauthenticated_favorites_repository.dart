import 'package:pokedex_app/features/favorites/domain/repositories/favorites_repository.dart';

/// Read-only empty favorites for unauthenticated users.
class const UnauthenticatedFavoritesRepository()
    implements FavoritesRepository {
  static const _empty = <int>{};

  @override
  Future<Set<int>> getFavoriteIds() async => _empty;

  @override
  Future<bool> isFavorite(int pokemonId) async => false;

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> toggleFavorite(int pokemonId) async {}

  @override
  Stream<Set<int>> watchFavoriteIds() => Stream.value(_empty);
}
