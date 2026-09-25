import 'package:flutter/foundation.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_round.dart';

/// Immutable progress for one local game session.
@immutable
class GameSession {
  new({
    this.score = 0,
    this.isFinished = false,
    List<GameRound> rounds = const [],
  }) : rounds = List.unmodifiable(rounds);

  final int score;
  final bool isFinished;
  final List<GameRound> rounds;
}
