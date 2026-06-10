import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/favorites/data/repositories/local_favorites_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('toggleFavorite adds and removes ids', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalFavoritesRepository(prefs);

    expect(await repo.getFavoriteIds(), isEmpty);

    await repo.toggleFavorite(25);
    expect(await repo.getFavoriteIds(), {25});
    expect(await repo.isFavorite(25), isTrue);

    await repo.toggleFavorite(25);
    expect(await repo.getFavoriteIds(), isEmpty);
    expect(await repo.isFavorite(25), isFalse);
  });

  test('replaceAll overwrites cached ids', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalFavoritesRepository(prefs);

    await repo.toggleFavorite(1);
    await repo.replaceAll({2, 3});

    expect(await repo.getFavoriteIds(), {2, 3});
  });

  test('watchFavoriteIds emits after toggle', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalFavoritesRepository(prefs);
    final values = <Set<int>>[];

    final sub = repo.watchFavoriteIds().listen(values.add);
    await repo.toggleFavorite(1);

    await Future<void>.delayed(Duration.zero);
    expect(values.last, {1});

    await sub.cancel();
    repo.dispose();
  });
}
