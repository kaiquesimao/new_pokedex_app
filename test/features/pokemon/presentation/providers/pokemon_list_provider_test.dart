import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_ref.dart';
import 'package:pokedex_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_list_provider.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _createContainer({
  required PokemonRepository repository,
  ProfileSettings? initialSettings,
}) async {
  SharedPreferences.setMockInitialValues(
    initialSettings == null
        ? {}
        : {
            if (!initialSettings.showMegaEvolutions)
              showMegaEvolutionsKey: false,
            if (!initialSettings.showOtherForms) showOtherFormsKey: false,
          },
  );
  final prefs = await SharedPreferences.getInstance();

  return ProviderContainer.test(
    overrides: [
      connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
      sharedPreferencesProvider.overrideWithValue(prefs),
      pokemonRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

class _OnlineConnectivity implements ConnectivityService {
  @override
  bool get isOnline => true;

  @override
  Stream<bool> get onlineStatus => Stream.value(true);

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> refresh() async => true;

  @override
  Future<void> dispose() async {}
}

class _FakePokemonRepository implements PokemonRepository {
  _FakePokemonRepository({
    this.refs = const [],
    this.sliceIds = const [1, 2, 10033],
  });

  final List<PokemonRef> refs;
  final List<int> sliceIds;

  @override
  Future<PokemonListSlice> getPokemonListSlice({
    required int offset,
    int limit = 20,
  }) async {
    return PokemonListSlice(
      ids: sliceIds,
      totalCount: sliceIds.length,
      hasMore: false,
      nextOffset: limit,
    );
  }

  @override
  Future<List<PokemonRef>> getAllPokemonRefs() async => refs;

  @override
  Future<PokemonSummary> getSummaryById(int id) async {
    final name = refs
        .where((ref) => ref.id == id)
        .map((ref) => ref.name)
        .firstOrNull;
    return PokemonSummary(
      id: id,
      slug: name ?? 'pokemon-$id',
      name: name ?? 'pokemon-$id',
      types: const [PokemonType.grass],
      spriteUrl: 'https://example.com/$id.png',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadInitial clears loading flags and exposes summaries', () async {
    final container = await _createContainer(
      repository: _FakePokemonRepository(
        refs: const [
          PokemonRef(id: 1, name: 'bulbasaur'),
          PokemonRef(id: 2, name: 'ivysaur'),
          PokemonRef(id: 10033, name: 'venusaur-mega'),
        ],
      ),
    );

    final notifier = container.read(pokemonListProvider.notifier);

    await notifier.loadInitial();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(pokemonListProvider);
    expect(state.isLoadingIds, isFalse);
    expect(state.isLoadingSummaries, isFalse);
    expect(state.showFullSkeleton, isFalse);
    expect(state.items, hasLength(3));
    expect(
      state.items.map((item) => item.name),
      ['bulbasaur', 'ivysaur', 'venusaur-mega'],
    );
  });

  test('reloads when mega evolutions preference changes', () async {
    final container = await _createContainer(
      repository: _FakePokemonRepository(
        sliceIds: const [1, 10033],
        refs: const [
          PokemonRef(id: 1, name: 'bulbasaur'),
          PokemonRef(id: 10033, name: 'venusaur-mega'),
        ],
      ),
      initialSettings: const ProfileSettings(),
    );

    final notifier = container.read(pokemonListProvider.notifier);
    await notifier.loadInitial();
    await Future<void>.delayed(Duration.zero);
    expect(container.read(pokemonListProvider).items, hasLength(2));

    await container
        .read(profileSettingsProvider.notifier)
        .setShowMegaEvolutions(value: false);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(pokemonListProvider).items, hasLength(1));
    expect(
      container.read(pokemonListProvider).items.single.name,
      'bulbasaur',
    );
  });
}
