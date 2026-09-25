import 'package:pokedex_app/features/guess_the_pokemon/data/datasources/guess_the_pokemon_local_datasource.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/datasources/guess_the_pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/repositories/guess_the_pokemon_repository.dart';

class GuessThePokemonRepositoryImpl implements GuessThePokemonRepository {
  new({required this._local, required this._remote});

  final GuessThePokemonLocalDataSource _local;
  final GuessThePokemonRemoteDataSource _remote;

  @override
  Future<GameSessionModel> startSession() async {
    final session = await _remote.startSession();
    await _local.saveSession(session);
    return session;
  }

  @override
  Future<AnswerResultModel> submitAnswer(
    AnswerSubmissionModel submission,
  ) => _remote.submitAnswer(submission);

  @override
  Future<LeaderboardPageModel> getLeaderboard({
    LeaderboardScope scope = LeaderboardScope.general,
    String? cursor,
  }) => _remote.getLeaderboard(scope: scope, cursor: cursor);

  @override
  Future<PublicationStateModel> publishScore(String sessionId) async {
    final state = await _remote.publishScore(sessionId);
    await _local.savePublicationState(state);
    return state;
  }

  @override
  Future<int> getBestScore() => _local.getBestScore();

  @override
  Future<void> saveBestScore(int score) => _local.saveBestScore(score);

  @override
  Future<bool> getPublicProfilePreference() => _readPublicProfilePreference();

  Future<bool> _readPublicProfilePreference() async {
    try {
      final value = await _remote.getGameProfilePreference();
      await _local.savePublicProfilePreference(value: value);
      return value;
    } on Object {
      return _local.getPublicProfilePreference();
    }
  }

  @override
  Future<void> savePublicProfilePreference({required bool value, String? displayName}) async {
    await _remote.updateGameProfile(
      isAnonymous: !value,
      displayName: value ? displayName : null,
    );
    await _local.savePublicProfilePreference(value: value);
  }

  @override
  Future<GameSessionModel?> readCachedSession() => _local.readSession();

  @override
  Future<PublicationStateModel?> readCachedPublicationState() =>
      _local.readPublicationState();

  @override
  Future<void> savePublicationState(PublicationStateModel state) =>
      _local.savePublicationState(state);

  @override
  Future<List<GameCatalogEntry>> loadLocalCatalog() => _local.loadCatalog();
}
