import 'package:flutter/foundation.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';

/// A single question with one correct answer and three alternatives.
@immutable
class GameRound {
  new({
    required this.sequenceNumber,
    required this.correctAnswer,
    required List<GameCatalogEntry> options,
  }) : options = List.unmodifiable(options),
       difficulty = correctAnswer.difficulty;

  final int sequenceNumber;
  final GameCatalogEntry correctAnswer;
  final List<GameCatalogEntry> options;
  final DifficultyBand difficulty;

  @override
  bool operator ==(Object other) =>
      other is GameRound &&
      other.sequenceNumber == sequenceNumber &&
      other.correctAnswer == correctAnswer &&
      _listsEqual(other.options, options);

  @override
  int get hashCode => Object.hash(sequenceNumber, correctAnswer, options);

  static bool _listsEqual(
    List<GameCatalogEntry> first,
    List<GameCatalogEntry> second,
  ) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }
}
