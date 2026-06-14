import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_filters_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_list_provider.dart';

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
  @override
  Future<PokemonListSlice> getPokemonListSlice({
    required int offset,
    int limit = 20,
  }) async {
    return PokemonListSlice(
      ids: const [1, 2],
      totalCount: 2,
      hasMore: false,
      nextOffset: limit,
    );
  }

  @override
  Future<PokemonSummary> getSummaryById(int id) async {
    return PokemonSummary(
      id: id,
      name: 'pokemon-$id',
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
    final connectivity = _OnlineConnectivity();

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = PokemonListNotifier(
      _FakePokemonRepository(),
      container.read(pokemonFiltersProvider.notifier),
      connectivity,
    );
    addTearDown(notifier.dispose);

    final loadFuture = notifier.loadInitial();
    await loadFuture;
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.isLoadingIds, isFalse);
    expect(notifier.state.isLoadingSummaries, isFalse);
    expect(notifier.state.showFullSkeleton, isFalse);
    expect(notifier.state.items, hasLength(2));
    expect(notifier.state.items.first.name, 'pokemon-1');
  });
}
