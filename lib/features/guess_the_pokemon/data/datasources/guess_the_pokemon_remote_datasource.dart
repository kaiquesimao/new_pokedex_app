import 'package:pokedex_app/core/network/guess_the_pokemon_api_client.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/repositories/guess_the_pokemon_repository.dart';

class GuessThePokemonRemoteDataSource {
  new(this._client);

  final GuessThePokemonApiClient _client;

  Future<GameSessionModel> startSession() async {
    return _guard(() async {
      final json = await _client.startSession();
      return GameSessionModel.fromJson(json);
    });
  }

  Future<AnswerResultModel> submitAnswer(
    AnswerSubmissionModel submission,
  ) async {
    return _guard(() async {
      final json = await _client.submitAnswer(
        submission.sessionId,
        submission.toJson(),
      );
      return AnswerResultModel.fromJson(json);
    });
  }

  Future<LeaderboardPageModel> getLeaderboard({
    LeaderboardScope scope = LeaderboardScope.general,
    String? cursor,
  }) async {
    return _guard(() async {
      final json = await _client.getLeaderboard(
        scope: scope == LeaderboardScope.general ? 'global' : 'weekly',
        cursor: cursor,
      );
      return LeaderboardPageModel.fromJson(json);
    });
  }

  Future<PublicationStateModel> publishScore(
    String sessionId,
    {int? score}
  ) async {
    return _guard(() async {
      final json = await _client.publishScore(
        sessionId,
      );
      return PublicationStateModel.fromJson({...json, 'sessionId': sessionId, 'score': score ?? 0});
    });
  }

  Future<void> updateGameProfile({
    required bool isAnonymous,
    required String? displayName,
  }) async {
    await _guard(() => _client.updateGameProfile(
      isAnonymous: isAnonymous,
      displayName: displayName,
    ));
  }

  Future<bool> getGameProfilePreference() async {
    return _guard(() async {
      final json = await _client.getGameProfile();
      return !(json['isAnonymous'] as bool? ?? true);
    });
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on GuessThePokemonException {
      rethrow;
    } on Object catch (error) {
      throw GuessThePokemonException.fromError(error);
    }
  }
}
