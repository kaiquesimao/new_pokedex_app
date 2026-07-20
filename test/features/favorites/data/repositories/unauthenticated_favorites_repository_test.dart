import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/favorites/data/repositories/unauthenticated_favorites_repository.dart';

void main() {
  const repo = UnauthenticatedFavoritesRepository();

  test('getFavoriteIds returns empty set', () async {
    expect(await repo.getFavoriteIds(), isEmpty);
  });

  test('isFavorite always returns false', () async {
    expect(await repo.isFavorite(25), isFalse);
  });

  test('toggleFavorite is a no-op', () async {
    await repo.toggleFavorite(25);
    expect(await repo.getFavoriteIds(), isEmpty);
  });

  test('clearAll is a no-op', () async {
    await repo.clearAll();
  });

  test('watchFavoriteIds emits empty set', () async {
    final values = <Set<int>>[];
    final sub = repo.watchFavoriteIds().listen(values.add);

    await Future<void>.delayed(Duration.zero);
    expect(values.first, isEmpty);

    await sub.cancel();
  });
}
