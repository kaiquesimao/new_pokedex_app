import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/constants/pokemon_types.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex_app/features/pokemon/domain/repositories/pokemon_repository.dart';
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
    final container = ProviderContainer.test(
      overrides: [
        connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
        pokemonRepositoryProvider.overrideWithValue(_FakePokemonRepository()),
      ],
    );

    final notifier = container.read(pokemonListProvider.notifier);

    await notifier.loadInitial();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(pokemonListProvider);
    expect(state.isLoadingIds, isFalse);
    expect(state.isLoadingSummaries, isFalse);
    expect(state.showFullSkeleton, isFalse);
    expect(state.items, hasLength(2));
    expect(state.items.first.name, 'pokemon-1');
  });
}
