abstract class FavoritesRepository {
  Future<Set<int>> getFavoriteIds();

  Future<void> clearAll();

  Future<void> toggleFavorite(int pokemonId);

  Future<bool> isFavorite(int pokemonId);

  /// Stream for remote sync (Firestore). Local impl emits once.
  Stream<Set<int>> watchFavoriteIds();
}
