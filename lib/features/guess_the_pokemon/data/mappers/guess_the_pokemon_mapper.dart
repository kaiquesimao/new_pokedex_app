import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_result.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_round.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_session.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/leaderboard_entry.dart';

extension AnswerResultModelMapping on AnswerResultModel {
  GameResult toDomain({
    required GameRound round,
    required GameSession session,
  }) {
    return GameResult(
      round: round,
      session: session,
      isCorrect: correct,
      pointsAwarded: correct ? 1 : 0,
    );
  }
}

extension LeaderboardEntryModelMapping on LeaderboardEntryModel {
  LeaderboardEntry toDomain() => LeaderboardEntry(
    playerName: playerName,
    score: score,
    completedAt: completedAt,
    isCurrentUser: isCurrentUser,
  );
}
