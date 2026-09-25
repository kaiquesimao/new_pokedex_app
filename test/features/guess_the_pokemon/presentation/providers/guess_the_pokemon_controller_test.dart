import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/repositories/guess_the_pokemon_repository.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/services/guess_the_pokemon_engine.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/providers/guess_the_pokemon_providers.dart';

void main() {
  test('guest starts a local round and records a local best score', () async {
    final repository = _FakeRepository();
    final container = _container(repository: repository);
    final controller = container.read(
      guessThePokemonControllerProvider.notifier,
    );

    await controller.start();
    final round = container.read(guessThePokemonControllerProvider).localRound!;
    await controller.selectAnswer(round.correctAnswer.speciesId);

    final state = container.read(guessThePokemonControllerProvider);
    expect(state.status, GuessThePokemonStatus.playing);
    expect(state.score, 1);
    expect(repository.bestScore, 1);
  });

  test('each new local game shuffles the species order', () async {
    final repository = _FakeRepository();
    final container = _container(repository: repository);
    final controller = container.read(
      guessThePokemonControllerProvider.notifier,
    );

    final firstAnswers = <int>[];
    for (var index = 0; index < 20; index++) {
      await controller.start();
      firstAnswers.add(
        container
            .read(guessThePokemonControllerProvider)
            .localRound!
            .correctAnswer
            .speciesId,
      );
    }

    expect(firstAnswers.toSet(), hasLength(greaterThan(1)));
  });

  test('remote mode uses the server current and next rounds exactly', () async {
    final repository = _FakeRepository(
      answerResult: AnswerResultModel(
        correct: true,
        score: 1,
        finished: false,
        nextRound: GameRoundModel(
          roundIndex: 8,
          options: const [
            GameRoundOptionModel(id: 404, name: '404'),
            GameRoundOptionModel(id: 505, name: '505'),
            GameRoundOptionModel(id: 606, name: '606'),
            GameRoundOptionModel(id: 707, name: '707'),
          ],
        ),
      ),
    );
    final container = _container(
      repository: repository,
      authenticated: true,
      failEngine: true,
    );
    final controller = container.read(
      guessThePokemonControllerProvider.notifier,
    );

    await controller.start();
    final initial = container.read(guessThePokemonControllerProvider);
    expect(initial.remoteRound?.roundIndex, 7);
    expect(initial.remoteRound?.options.map((option) => option.id), [
      101,
      202,
      303,
      404,
    ]);

    await controller.selectAnswer(303);

    final state = container.read(guessThePokemonControllerProvider);
    expect(repository.submission?.roundIndex, 7);
    expect(repository.submission?.optionId, 303);
    expect(state.remoteRound?.roundIndex, 8);
    expect(state.remoteRound?.options.map((option) => option.id), [
      404,
      505,
      606,
      707,
    ]);
  });

  test('authenticated start failure falls back to local play', () async {
    final repository = _FakeRepository(startError: StateError('offline'));
    final container = _container(repository: repository, authenticated: true);

    await container.read(guessThePokemonControllerProvider.notifier).start();

    final state = container.read(guessThePokemonControllerProvider);
    expect(state.status, GuessThePokemonStatus.playing);
    expect(state.isRemote, isFalse);
    expect(state.canPublish, isFalse);
  });

  test('remote answer failure keeps the same session for retry', () async {
    final repository = _FakeRepository(answerError: StateError('offline'));
    final container = _container(repository: repository, authenticated: true);
    final controller = container.read(
      guessThePokemonControllerProvider.notifier,
    );

    await controller.start();
    await controller.selectAnswer(303);
    final state = container.read(guessThePokemonControllerProvider);
    expect(state.isRemote, isTrue);
    expect(state.remoteRound?.roundIndex, 7);
    expect(state.pendingSubmission?.optionId, 303);
    expect(state.sessionId, 'server-session');
  });

  test('retries an answer when the server accepted it before the response was lost', () async {
    final repository = _FakeRepository(
      answerErrorOnce: StateError('response lost'),
      answerResult: AnswerResultModel(
        correct: true,
        score: 1,
        finished: false,
        nextRound: GameRoundModel(
          roundIndex: 8,
          silhouetteUrl: 'https://example.test/next.png',
          options: const [
            GameRoundOptionModel(id: 404, name: '404'),
            GameRoundOptionModel(id: 505, name: '505'),
            GameRoundOptionModel(id: 606, name: '606'),
            GameRoundOptionModel(id: 707, name: '707'),
          ],
        ),
      ),
    );
    final container = _container(repository: repository, authenticated: true);
    addTearDown(container.dispose);
    final controller = container.read(
      guessThePokemonControllerProvider.notifier,
    );

    await controller.start();
    await controller.selectAnswer(303);
    await controller.retryAnswer();

    expect(repository.submission?.optionId, 303);
    expect(
      container.read(guessThePokemonControllerProvider).remoteRound?.roundIndex,
      8,
    );
  });

  test('late answer response cannot resurrect an abandoned game', () async {
    final answerCompleter = Completer<AnswerResultModel>();
    final repository = _FakeRepository(answerCompleter: answerCompleter);
    final container = _container(repository: repository, authenticated: true);
    final controller = container.read(
      guessThePokemonControllerProvider.notifier,
    );

    await controller.start();
    final answerRequest = controller.selectAnswer(303);
    controller.abandon();
    answerCompleter.complete(
      const AnswerResultModel(
        correct: false,
        score: 0,
        finished: true,
      ),
    );
    await answerRequest;

    expect(
      container.read(guessThePokemonControllerProvider).status,
      GuessThePokemonStatus.idle,
    );
  });

  test('publication retry is ignored after the score is published', () async {
    final repository = _FakeRepository(
      answerResult: const AnswerResultModel(
        correct: false,
        score: 0,
        finished: true,
      ),
    );
    final container = _container(repository: repository, authenticated: true);
    final controller = container.read(
      guessThePokemonControllerProvider.notifier,
    );

    await controller.start();
    await controller.selectAnswer(303);
    await controller.retryPublication();
    await controller.retryPublication();

    expect(repository.publishCalls, 1);
    expect(
      container.read(guessThePokemonControllerProvider).publicationState,
      PublicationState.published,
    );
  });

  test('recovers a pending publication after controller restart', () async {
    final repository = _FakeRepository(
      cachedPublication: const PublicationStateModel(
        state: PublicationState.pending,
        sessionId: 'recovered-session',
        score: 4,
      ),
    );
    final container = _container(repository: repository, authenticated: true);
    addTearDown(container.dispose);

    container.read(guessThePokemonControllerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = container.read(guessThePokemonControllerProvider);
    expect(state.sessionId, 'recovered-session');
    expect(state.publicationState, PublicationState.failed);
    expect(state.canPublish, isTrue);
    await container
        .read(guessThePokemonControllerProvider.notifier)
        .retryPublication();
    expect(repository.publishCalls, 1);
    expect(
      container.read(guessThePokemonControllerProvider).publicationState,
      PublicationState.published,
    );
  });

  test('recovered pending publication exposes retry after failure', () async {
    final repository = _FakeRepository(
      cachedPublication: const PublicationStateModel(
        state: PublicationState.pending,
        sessionId: 'recovered-session',
        score: 4,
      ),
      publishErrors: [StateError('offline')],
    );
    final container = _container(repository: repository, authenticated: true);
    addTearDown(container.dispose);
    container.read(guessThePokemonControllerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = container.read(guessThePokemonControllerProvider);
    expect(state.publicationState, PublicationState.failed);
    expect(state.canPublish, isTrue);
    await container
        .read(guessThePokemonControllerProvider.notifier)
        .retryPublication();
    expect(
      container.read(guessThePokemonControllerProvider).publicationState,
      PublicationState.failed,
    );
  });

  test(
    'publication failure can be retried without blocking anonymous display',
    () async {
      final repository = _FakeRepository(
        publishErrors: [StateError('offline')],
      );
      final container = _container(repository: repository, authenticated: true);
      final controller = container.read(
        guessThePokemonControllerProvider.notifier,
      );

      await controller.start();
      await controller.selectAnswer(303);
      expect(
        container.read(guessThePokemonControllerProvider).publicationState,
        PublicationState.failed,
      );
      await controller.retryPublication();

      expect(repository.publishCalls, 2);
      expect(
        container.read(guessThePokemonControllerProvider).publicationState,
        PublicationState.published,
      );
    },
  );

  test('local engine errors are exposed as an error state', () async {
    final container = ProviderContainer.test(
      overrides: [
        guessThePokemonRepositoryProvider.overrideWithValue(_FakeRepository()),
        guessThePokemonEngineProvider.overrideWith(
          (ref) => throw StateError('invalid local catalog'),
        ),
      ],
    );

    await container.read(guessThePokemonControllerProvider.notifier).start();

    expect(
      container.read(guessThePokemonControllerProvider).status,
      GuessThePokemonStatus.error,
    );
    container.dispose();
  });
}

ProviderContainer _container({
  required GuessThePokemonRepository repository,
  bool authenticated = false,
  bool failEngine = false,
}) {
  return ProviderContainer.test(
    overrides: [
      guessThePokemonRepositoryProvider.overrideWithValue(repository),
      guessThePokemonEngineProvider.overrideWith(
        (ref) => failEngine
            ? throw StateError('local engine must not be used')
            : GuessThePokemonEngine(catalog: _catalog, seed: 7),
      ),
      guessThePokemonAuthenticatedProvider.overrideWithValue(authenticated),
    ],
  );
}

final List<GameCatalogEntry> _catalog = [
  ...List.generate(
    4,
    (i) => GameCatalogEntry(
      speciesId: i + 1,
      name: 'Easy ${i + 1}',
      difficulty: DifficultyBand.easy,
    ),
  ),
  ...List.generate(
    4,
    (i) => GameCatalogEntry(
      speciesId: i + 5,
      name: 'Medium ${i + 5}',
      difficulty: DifficultyBand.medium,
    ),
  ),
  ...List.generate(
    4,
    (i) => GameCatalogEntry(
      speciesId: i + 9,
      name: 'Hard ${i + 9}',
      difficulty: DifficultyBand.hard,
    ),
  ),
];

final _serverSession = GameSessionModel(
  sessionId: 'server-session',
  catalogVersion: 'v1',
  round: GameRoundModel(
    roundIndex: 7,
    options: const [
      GameRoundOptionModel(id: 101, name: '101'),
      GameRoundOptionModel(id: 202, name: '202'),
      GameRoundOptionModel(id: 303, name: '303'),
      GameRoundOptionModel(id: 404, name: '404'),
    ],
  ),
);

class _FakeRepository implements GuessThePokemonRepository {
  new({
    this.startError,
    this.answerError,
    this.answerResult,
    this.answerCompleter,
    this.answerErrorOnce,
    this.cachedPublication,
    this.publishErrors = const [],
  });

  final Error? startError;
  final Error? answerError;
  final AnswerResultModel? answerResult;
  final Completer<AnswerResultModel>? answerCompleter;
  final Error? answerErrorOnce;
  final PublicationStateModel? cachedPublication;
  final List<Error> publishErrors;
  int bestScore = 0;
  int publishCalls = 0;
  int answerCalls = 0;
  AnswerSubmissionModel? submission;

  @override
  Future<GameSessionModel> startSession() async {
    if (startError != null) throw startError!;
    return _serverSession;
  }

  @override
  Future<AnswerResultModel> submitAnswer(
    AnswerSubmissionModel submission,
  ) async {
    this.submission = submission;
    if (answerError != null) throw answerError!;
    if (answerErrorOnce != null && answerCalls++ == 0) throw answerErrorOnce!;
    if (answerCompleter != null) return answerCompleter!.future;
    return answerResult ??
        const AnswerResultModel(
          correct: false,
          score: 0,
          finished: true,
        );
  }

  @override
  Future<LeaderboardPageModel> getLeaderboard({
    LeaderboardScope scope = LeaderboardScope.general,
    String? cursor,
  }) async => LeaderboardPageModel(entries: const []);

  @override
  Future<PublicationStateModel> publishScore(String sessionId) async {
    publishCalls++;
    if (publishCalls <= publishErrors.length) {
      throw publishErrors[publishCalls - 1];
    }
    return const PublicationStateModel(state: PublicationState.published);
  }

  @override
  Future<int> getBestScore() async => bestScore;

  @override
  Future<void> saveBestScore(int score) async => bestScore = score;

  @override
  Future<bool> getPublicProfilePreference() async => false;

  @override
  Future<void> savePublicProfilePreference({
    required bool value,
    String? displayName,
  }) async {}

  @override
  Future<List<GameCatalogEntry>> loadLocalCatalog() async => _catalog;

  @override
  Future<void> savePublicationState(PublicationStateModel state) async {}

  @override
  Future<GameSessionModel?> readCachedSession() async => null;

  @override
  Future<PublicationStateModel?> readCachedPublicationState() async =>
      cachedPublication;
}
