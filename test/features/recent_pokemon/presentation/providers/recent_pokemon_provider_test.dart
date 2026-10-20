import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex_app/features/recent_pokemon/domain/recent_pokemon_history.dart';
import 'package:pokedex_app/features/recent_pokemon/presentation/providers/recent_pokemon_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecentPokemonNotifier', () {
    test('record persists most-recent-first and dedupes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(recentPokemonProvider.notifier);
      await notifier.record(1);
      await notifier.record(2);
      await notifier.record(1);

      expect(container.read(recentPokemonProvider), [1, 2]);
      expect(prefs.getStringList(recentPokemonIdsKey), ['1', '2']);
    });

    test('record ignores non-positive ids and caps the history', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(recentPokemonProvider.notifier);
      await notifier.record(0);
      await notifier.record(-5);
      for (var id = 1; id <= 13; id++) {
        await notifier.record(id);
      }

      expect(container.read(recentPokemonProvider), [
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
      expect(
        readRecentPokemonIds(prefs),
        container.read(recentPokemonProvider),
      );
    });

    test('clear removes the stored history', () async {
      SharedPreferences.setMockInitialValues({
        recentPokemonIdsKey: ['4', '7'],
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(recentPokemonProvider), [4, 7]);

      await container.read(recentPokemonProvider.notifier).clear();

      expect(container.read(recentPokemonProvider), isEmpty);
      expect(prefs.getStringList(recentPokemonIdsKey), isNull);
    });
  });

  group('recentPokemonSummariesProvider', () {
    test('reorders summaries to match history and drops misses', () async {
      SharedPreferences.setMockInitialValues({
        recentPokemonIdsKey: ['3', '1', '9'],
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          pokemonRepositoryProvider.overrideWithValue(
            _FakePokemonRepository(summaries: [_summary(1), _summary(3)]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final summaries = await container.read(
        recentPokemonSummariesProvider.future,
      );

      expect(summaries.map((summary) => summary.id).toList(), [3, 1]);
    });

    test('returns an empty list when summaries fail to load', () async {
      SharedPreferences.setMockInitialValues({
        recentPokemonIdsKey: ['1'],
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          pokemonRepositoryProvider.overrideWithValue(
            _FakePokemonRepository(throwOnSummaries: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final summaries = await container.read(
        recentPokemonSummariesProvider.future,
      );

      expect(summaries, isEmpty);
    });
  });
}

PokemonSummary _summary(int id) {
  return PokemonSummary(
    id: id,
    slug: 'pokemon-$id',
    name: 'Pokemon $id',
    types: const [PokemonType.grass],
  );
}

class _FakePokemonRepository implements PokemonRepository {
  new({this.summaries = const [], this.throwOnSummaries = false});

  final List<PokemonSummary> summaries;
  final bool throwOnSummaries;

  @override
  Future<List<PokemonSummary>> getSummariesByIds(
    List<int> ids, {
    PokemonListFilters? filters,
    Set<PokemonType>? weakToTypes,
  }) async {
    if (throwOnSummaries) throw Exception('summaries failed');
    return summaries;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
