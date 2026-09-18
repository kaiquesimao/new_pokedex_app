import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/network/guess_the_pokemon_api_client.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/datasources/guess_the_pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';

void main() {
  test('delegates every game operation to the dedicated API client', () async {
    final client = _FakeGameApiClient();
    final remote = GuessThePokemonRemoteDataSource(client);

    await remote.startSession();
    await remote.submitAnswer(
      const AnswerSubmissionModel(
        sessionId: 'session-1',
        roundIndex: 1,
        optionId: 25,
      ),
    );
    await remote.getLeaderboard(cursor: 'next');
    await remote.publishScore('session-1');

    expect(client.calls, [
      'start',
      'answer',
      'leaderboard:global:next',
      'publish:session-1',
    ]);
  });

  test('converts API failures to typed feature errors', () async {
    final remote = GuessThePokemonRemoteDataSource(
      _FakeGameApiClient(error: const NetworkException()),
    );

    await expectLater(
      remote.startSession(),
      throwsA(
        isA<GuessThePokemonException>().having(
          (error) => error.code,
          'code',
          GuessThePokemonErrorCode.network,
        ),
      ),
    );
  });

  test('converts profile sync failures to typed feature errors', () async {
    final remote = GuessThePokemonRemoteDataSource(
      _FakeGameApiClient(error: const NetworkException()),
    );

    await expectLater(
      remote.updateGameProfile(isAnonymous: false, displayName: 'Ash'),
      throwsA(
        isA<GuessThePokemonException>().having(
          (error) => error.code,
          'code',
          GuessThePokemonErrorCode.network,
        ),
      ),
    );
  });

  test('reads the remote public profile preference', () async {
    final remote = GuessThePokemonRemoteDataSource(_FakeGameApiClient());

    expect(await remote.getGameProfilePreference(), isTrue);
  });

  test('reports an unconfigured game API as unavailable', () async {
    final remote = GuessThePokemonRemoteDataSource(
      GuessThePokemonApiClient(Dio(BaseOptions(baseUrl: ''))),
    );

    await expectLater(
      remote.startSession(),
      throwsA(
        isA<GuessThePokemonException>().having(
          (error) => error.code,
          'code',
          GuessThePokemonErrorCode.unavailable,
        ),
      ),
    );
  });
}

class _FakeGameApiClient extends GuessThePokemonApiClient {
  _FakeGameApiClient({this.error}) : super(Dio());

  final Exception? error;
  final calls = <String>[];

  @override
  Future<Map<String, dynamic>> startSession() async {
    if (error != null) throw error!;
    calls.add('start');
    return _sessionJson;
  }

  @override
  Future<Map<String, dynamic>> submitAnswer(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    if (error != null) throw error!;
    calls.add('answer');
    return _answerJson;
  }

  @override
  Future<Map<String, dynamic>> getLeaderboard({
    required String scope,
    String? cursor,
  }) async {
    if (error != null) throw error!;
    calls.add('leaderboard:$scope:$cursor');
    return {'entries': <Map<String, dynamic>>[]};
  }

  @override
  Future<Map<String, dynamic>> publishScore(
    String sessionId,
  ) async {
    if (error != null) throw error!;
    calls.add('publish:$sessionId');
    return {'state': 'published'};
  }

  @override
  Future<Map<String, dynamic>> updateGameProfile({
    required bool isAnonymous,
    required String? displayName,
  }) async {
    if (error != null) throw error!;
    calls.add('profile:$isAnonymous:$displayName');
    return {};
  }

  @override
  Future<Map<String, dynamic>> getGameProfile() async {
    if (error != null) throw error!;
    return {'isAnonymous': false, 'displayName': 'Ash'};
  }
}

const _sessionJson = <String, dynamic>{
  'sessionId': 'session-1',
  'catalogVersion': 'v1',
  'round': <String, dynamic>{'roundIndex': 0, 'options': <dynamic>[]},
};

const _answerJson = <String, dynamic>{
  'correct': true,
  'score': 1,
  'finished': false,
};
