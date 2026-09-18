import 'package:flutter/foundation.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_round.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_session.dart';

/// Outcome of answering a round, including the resulting immutable session.
@immutable
class const GameResult({
  required final GameRound round,
  required final GameSession session,
  required final bool isCorrect,
  required final int pointsAwarded,
});
