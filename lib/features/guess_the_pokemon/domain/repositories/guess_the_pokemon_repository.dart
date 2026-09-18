import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';

enum LeaderboardScope { general, weekly }

abstract interface class GuessThePokemonRepository {
  Future<GameSessionModel> startSession();

  Future<AnswerResultModel> submitAnswer(AnswerSubmissionModel submission);

  Future<LeaderboardPageModel> getLeaderboard({
    LeaderboardScope scope = LeaderboardScope.general,
    String? cursor,
  });

  Future<PublicationStateModel> publishScore(String sessionId);

  Future<int> getBestScore();

  Future<void> saveBestScore(int score);

  Future<bool> getPublicProfilePreference();

  Future<void> savePublicProfilePreference({required bool value, String? displayName});

  Future<GameSessionModel?> readCachedSession();

  Future<PublicationStateModel?> readCachedPublicationState();

  Future<void> savePublicationState(PublicationStateModel state);

  Future<List<GameCatalogEntry>> loadLocalCatalog();
}
