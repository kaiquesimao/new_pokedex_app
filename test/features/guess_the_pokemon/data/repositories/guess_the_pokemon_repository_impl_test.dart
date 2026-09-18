import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/network/guess_the_pokemon_api_client.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/datasources/guess_the_pokemon_local_datasource.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/datasources/guess_the_pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/repositories/guess_the_pokemon_repository_impl.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/repositories/guess_the_pokemon_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'delegates game operations and persists session/publication state',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final local = _RecordingLocalDataSource(prefs);
      final remote = _RecordingRemoteDataSource();
      final repository = GuessThePokemonRepositoryImpl(
        local: local,
        remote: remote,
      );

      await repository.startSession();
      await repository.submitAnswer(
        const AnswerSubmissionModel(
          sessionId: 'session-1',
          roundIndex: 1,
          optionId: 25,
        ),
      );
      await repository.getLeaderboard(cursor: 'next');
      await repository.publishScore('session-1');
      await repository.saveBestScore(9);
       await repository.savePublicProfilePreference(value: true, displayName: 'Ash');

      expect(remote.calls, [
        'start',
        'answer',
        'leaderboard:general:next',
        'publish:session-1',
         'profile:false:Ash',
      ]);
      expect(local.savedSession?.sessionId, 'session-1');
      expect(local.savedPublication?.state, PublicationState.published);
      expect(await repository.getBestScore(), 9);
      expect(await repository.getPublicProfilePreference(), isTrue);
    },
  );

  test(
    'falls back to the local privacy preference when remote read fails',
    () async {
      SharedPreferences.setMockInitialValues({
        '${GuessThePokemonLocalDataSource.publicProfileKey}:guest': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = GuessThePokemonRepositoryImpl(
        local: GuessThePokemonLocalDataSource(prefs),
        remote: _RecordingRemoteDataSource(
          readProfileError: const NetworkException(),
        ),
      );

      expect(await repository.getPublicProfilePreference(), isTrue);
    },
  );
}

class _RecordingRemoteDataSource extends GuessThePokemonRemoteDataSource {
  _RecordingRemoteDataSource({this.readProfileError}) : super(_unusedClient);

  static final _unusedClient = GuessThePokemonApiClient(Dio());
  final calls = <String>[];
  final Object? readProfileError;

  @override
  Future<GameSessionModel> startSession() async {
    calls.add('start');
    return GameSessionModel(
      sessionId: 'session-1',
      catalogVersion: 'v1',
      round: GameRoundModel(roundIndex: 0, options: const []),
    );
  }

  @override
  Future<AnswerResultModel> submitAnswer(
    AnswerSubmissionModel submission,
  ) async {
    calls.add('answer');
    return const AnswerResultModel(
      correct: true,
      score: 1,
      finished: false,
    );
  }

  @override
  Future<LeaderboardPageModel> getLeaderboard({
    LeaderboardScope scope = LeaderboardScope.general,
    String? cursor,
  }) async {
    calls.add('leaderboard:${scope.name}:$cursor');
    return LeaderboardPageModel(entries: const []);
  }

  @override
  Future<PublicationStateModel> publishScore(
    String sessionId,
    {int? score}
  ) async {
    calls.add('publish:$sessionId');
    return const PublicationStateModel(state: PublicationState.published);
  }

  @override
  Future<void> updateGameProfile({
    required bool isAnonymous,
    required String? displayName,
  }) async {
    calls.add('profile:$isAnonymous:$displayName');
  }

  @override
  Future<bool> getGameProfilePreference() async {
    if (readProfileError != null) throw readProfileError!;
    return true;
  }
}

class _RecordingLocalDataSource extends GuessThePokemonLocalDataSource {
  _RecordingLocalDataSource(super.prefs);

  GameSessionModel? savedSession;
  PublicationStateModel? savedPublication;

  @override
  Future<void> saveSession(GameSessionModel session) async {
    savedSession = session;
    await super.saveSession(session);
  }

  @override
  Future<void> savePublicationState(PublicationStateModel state) async {
    savedPublication = state;
    await super.savePublicationState(state);
  }
}
