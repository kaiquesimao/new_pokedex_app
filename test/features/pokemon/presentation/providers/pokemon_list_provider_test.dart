import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_filters.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_ref.dart';
import 'package:pokedex_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_filters_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_list_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _createContainer({
  required PokemonRepository repository,
}) async {
  SharedPreferences.setMockInitialValues({});
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
  new({
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
  Future<void> warmPokemonNameIndex() async {}

  @override
  Future<PokemonSummary> getSummaryById(int id) async {
    final apiName = refs
        .where((ref) => ref.id == id)
        .map((ref) => ref.name)
        .firstOrNull;
    final slug = apiName ?? 'pokemon-$id';
    // Mimic production: display name differs from API slug for forms.
    final displayName = switch (slug) {
      'charizard-gmax' => 'Charizard Gigantamax',
      'rattata-alola' => 'Rattata Alola',
      'venusaur-mega' => 'Venusaur Mega',
      _ => slug,
    };
    final isDefault = !slug.contains('-');
    return PokemonSummary(
      id: id,
      slug: slug,
      name: displayName,
      types: const [PokemonType.grass],
      spriteUrl: 'https://example.com/$id.png',
      isDefault: isDefault,
      isMega: slug.contains('-mega'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadInitial defaults to default forms only', () async {
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
    expect(state.items, hasLength(2));
    expect(
      state.items.map((item) => item.name),
      ['bulbasaur', 'ivysaur'],
    );
  });

  test('reloads when mega form category is selected', () async {
    final container = await _createContainer(
      repository: _FakePokemonRepository(
        sliceIds: const [1, 10033],
        refs: const [
          PokemonRef(id: 1, name: 'bulbasaur'),
          PokemonRef(id: 10033, name: 'venusaur-mega'),
        ],
      ),
    );

    final notifier = container.read(pokemonListProvider.notifier);
    await notifier.loadInitial();
    await Future<void>.delayed(Duration.zero);
    expect(container.read(pokemonListProvider).items, hasLength(1));
    expect(
      container.read(pokemonListProvider).items.single.name,
      'bulbasaur',
    );

    container
        .read(pokemonFiltersProvider.notifier)
        .toggleFormCategory(PokemonFormCategory.mega);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(pokemonListProvider).items, hasLength(1));
    expect(
      container.read(pokemonListProvider).items.single.slug,
      'venusaur-mega',
    );
  });

  test('gigantamax and regional form filters return matching forms', () async {
    final container = await _createContainer(
      repository: _FakePokemonRepository(
        sliceIds: const [6, 10195, 10091],
        refs: const [
          PokemonRef(id: 6, name: 'charizard'),
          PokemonRef(id: 10195, name: 'charizard-gmax'),
          PokemonRef(id: 10091, name: 'rattata-alola'),
        ],
      ),
    );

    final notifier = container.read(pokemonListProvider.notifier);
    await notifier.loadInitial();
    await Future<void>.delayed(Duration.zero);

    container
        .read(pokemonFiltersProvider.notifier)
        .toggleFormCategory(PokemonFormCategory.gigantamax);
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(pokemonListProvider).items.map((e) => e.slug),
      ['charizard-gmax'],
    );

    container
        .read(pokemonFiltersProvider.notifier)
        .toggleFormCategory(PokemonFormCategory.gigantamax);
    container
        .read(pokemonFiltersProvider.notifier)
        .toggleFormCategory(PokemonFormCategory.regional);
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(pokemonListProvider).items.map((e) => e.slug),
      ['rattata-alola'],
    );
  });
}
