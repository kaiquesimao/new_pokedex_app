import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/recent_pokemon/domain/recent_pokemon_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseRecentPokemonIds', () {
    test('drops non-positive and unparsable values and dedupes', () {
      expect(parseRecentPokemonIds(['0', 'x', '4', '-2', '4', '7', '']), [
        4,
        7,
      ]);
    });

    test('keeps the first 12 ids', () {
      final raw = [for (var id = 1; id <= 15; id++) '$id'];
      expect(parseRecentPokemonIds(raw), [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
      ]);
    });

    test('returns empty for null or empty input', () {
      expect(parseRecentPokemonIds(null), isEmpty);
      expect(parseRecentPokemonIds(const []), isEmpty);
    });
  });

  group('pushRecentPokemonId', () {
    test('inserts the id at the front and moves duplicates', () {
      expect(pushRecentPokemonId(const [2, 3], 1), [1, 2, 3]);
      expect(pushRecentPokemonId(const [1, 2, 3], 2), [2, 1, 3]);
    });

    test('ignores non-positive ids', () {
      const current = [4, 7];
      expect(pushRecentPokemonId(current, 0), same(current));
      expect(pushRecentPokemonId(current, -1), same(current));
    });

    test('returns the same list when the id is already first', () {
      const current = [4, 7];
      expect(pushRecentPokemonId(current, 4), same(current));
    });

    test('drops the oldest id past the limit', () {
      final current = [for (var id = 12; id >= 1; id--) id];
      expect(pushRecentPokemonId(current, 13), [
        13,
        12,
        11,
        10,
        9,
        8,
        7,
        6,
        5,
        4,
        3,
        2,
      ]);
    });
  });

  group('readRecentPokemonIds', () {
    test('reads the stored string list', () async {
      SharedPreferences.setMockInitialValues({
        recentPokemonIdsKey: ['25', 'nope', '1'],
      });
      final prefs = await SharedPreferences.getInstance();

      expect(readRecentPokemonIds(prefs), [25, 1]);
    });
  });
}
