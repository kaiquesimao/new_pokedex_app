import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/repositories/guess_the_pokemon_repository.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/providers/leaderboard_provider.dart';

void main() {
  test('loads the selected scope and appends the next page', () async {
    final repository = _FakeLeaderboardRepository([
      LeaderboardPageModel(
        entries: [
          LeaderboardEntryModel(
            playerName: 'Misty',
            score: 8,
            completedAt: DateTime.utc(2026, 9, 17),
          ),
        ],
        nextCursor: 'next',
      ),
      LeaderboardPageModel(
        entries: [
          LeaderboardEntryModel(
            playerName: 'Brock',
            score: 7,
            completedAt: DateTime.utc(2026, 9, 16),
          ),
        ],
      ),
    ]);
    final container = ProviderContainer(
      overrides: [
        guessThePokemonRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(leaderboardProvider.notifier);
    await notifier.load(scope: LeaderboardScope.weekly);
    await notifier.loadMore();

    final state = container.read(leaderboardProvider);
    expect(repository.scopes, [
      LeaderboardScope.weekly,
      LeaderboardScope.weekly,
    ]);
    expect(repository.cursors, [null, 'next']);
    expect(state.entries.map((entry) => entry.playerName), ['Misty', 'Brock']);
    expect(state.hasMore, isFalse);
  });

  test('ignores a slower response from a previously selected scope', () async {
    final weekly = Completer<LeaderboardPageModel>();
    final repository = _FakeLeaderboardRepository.withRequests([
      () => weekly.future,
      () async => LeaderboardPageModel(
        entries: [
          LeaderboardEntryModel(
            playerName: 'Brock',
            score: 7,
            completedAt: DateTime.utc(2026, 9, 16),
          ),
        ],
      ),
    ]);
    final container = ProviderContainer(
      overrides: [
        guessThePokemonRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(leaderboardProvider.notifier);
    final oldRequest = notifier.load(scope: LeaderboardScope.weekly);
    await notifier.load(scope: LeaderboardScope.general);
    weekly.complete(
      LeaderboardPageModel(
        entries: [
          LeaderboardEntryModel(
            playerName: 'Misty',
            score: 8,
            completedAt: DateTime.utc(2026, 9, 17),
          ),
        ],
      ),
    );
    await oldRequest;

    final state = container.read(leaderboardProvider);
    expect(state.scope, LeaderboardScope.general);
    expect(state.entries.single.playerName, 'Brock');
  });

  test('keeps a typed error and retries after an offline failure', () async {
    final repository = _FakeLeaderboardRepository.withRequests([
      () async => throw const GuessThePokemonException(
        GuessThePokemonErrorCode.network,
      ),
      () async => LeaderboardPageModel(entries: const []),
    ]);
    final container = ProviderContainer(
      overrides: [
        guessThePokemonRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(leaderboardProvider.notifier);

    await notifier.load();
    expect(
      container.read(leaderboardProvider).error,
      isA<GuessThePokemonException>(),
    );
    await notifier.load();
    expect(
      container.read(leaderboardProvider).status,
      LeaderboardStatus.loaded,
    );
  });
}

class _FakeLeaderboardRepository implements GuessThePokemonRepository {
  _FakeLeaderboardRepository(this.pages)
    : requests = [for (final page in pages) () async => page];

  _FakeLeaderboardRepository.withRequests(this.requests) : pages = const [];

  final List<LeaderboardPageModel> pages;
  final List<Future<LeaderboardPageModel> Function()> requests;
  final scopes = <LeaderboardScope>[];
  final cursors = <String?>[];
  var index = 0;

  @override
  Future<LeaderboardPageModel> getLeaderboard({
    LeaderboardScope scope = LeaderboardScope.general,
    String? cursor,
  }) async {
    scopes.add(scope);
    cursors.add(cursor);
    return requests[index++]();
  }

  @override
  Future<GameSessionModel> startSession() => throw UnimplementedError();

  @override
  Future<AnswerResultModel> submitAnswer(AnswerSubmissionModel submission) =>
      throw UnimplementedError();

  @override
  Future<PublicationStateModel> publishScore(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<int> getBestScore() => throw UnimplementedError();

  @override
  Future<void> saveBestScore(int score) => throw UnimplementedError();

  @override
  Future<bool> getPublicProfilePreference() => throw UnimplementedError();

  @override
  Future<void> savePublicProfilePreference({required bool value, String? displayName}) =>
      throw UnimplementedError();

  @override
  Future<List<GameCatalogEntry>> loadLocalCatalog() => throw UnimplementedError();

  @override
  Future<void> savePublicationState(PublicationStateModel state) => throw UnimplementedError();

  @override
  Future<GameSessionModel?> readCachedSession() => throw UnimplementedError();

  @override
  Future<PublicationStateModel?> readCachedPublicationState() =>
      throw UnimplementedError();
}
