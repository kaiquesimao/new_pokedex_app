import 'dart:math';

import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_result.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_round.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_session.dart';

/// Builds deterministic local rounds and applies the game's scoring rules.
class GuessThePokemonEngine {
  GuessThePokemonEngine({
    required List<GameCatalogEntry> catalog,
    this.seed = 0,
  }) : _catalog = _validatedCatalog(catalog) {
    _sequence = _buildSequence(_catalog, seed);
  }

  final int seed;
  final List<GameCatalogEntry> _catalog;
  late final List<GameCatalogEntry> _sequence;

  /// Starts a new session with no answered rounds.
  GameSession startSession() => GameSession();

  /// Whether the session can produce another non-repeated species.
  bool hasNextRound(GameSession session) =>
      !session.isFinished;

  /// Creates the next round without mutating the supplied session.
  GameRound nextRound(GameSession session) {
    if (session.isFinished) {
      throw StateError('A finished session cannot create another round.');
    }
    final index = session.rounds.length;
    final correctAnswer = _sequence[index % _sequence.length];
    final sameBand =
        _catalog
            .where(
              (entry) =>
                  entry.difficulty == correctAnswer.difficulty &&
                  entry.speciesId != correctAnswer.speciesId,
            )
            .toList()
          ..shuffle(Random(_roundSeed(index)));
    if (sameBand.length < 3) {
      throw StateError(
        'Each difficulty band needs at least four catalog entries.',
      );
    }

    final options = <GameCatalogEntry>[
      correctAnswer,
      ...sameBand.take(3),
    ]..shuffle(Random(_roundSeed(index) + 1));
    return GameRound(
      sequenceNumber: index,
      correctAnswer: correctAnswer,
      options: options,
    );
  }

  /// Applies an answer; the first wrong answer ends the session.
  GameResult answer(
    GameSession session,
    GameRound round,
    GameCatalogEntry selectedAnswer,
  ) {
    if (session.isFinished) {
      throw StateError('A finished session cannot be answered.');
    }
    if (round.sequenceNumber != session.rounds.length) {
      throw StateError('The round does not belong to the current session.');
    }

    final isCorrect = selectedAnswer == round.correctAnswer;
    final nextSession = GameSession(
      score: session.score + (isCorrect ? 1 : 0),
      isFinished: !isCorrect,
      rounds: [...session.rounds, round],
    );
    return GameResult(
      round: round,
      session: nextSession,
      isCorrect: isCorrect,
      pointsAwarded: isCorrect ? 1 : 0,
    );
  }

  int _roundSeed(int index) => seed ^ (index * 0x9E3779B9);

  static List<GameCatalogEntry> _validatedCatalog(
    List<GameCatalogEntry> catalog,
  ) {
    final entries = List<GameCatalogEntry>.unmodifiable(catalog);
    final speciesIds = entries.map((entry) => entry.speciesId).toSet();
    if (speciesIds.length != entries.length) {
      throw ArgumentError('Catalog species IDs must be unique.');
    }
    if (entries.length < 4) {
      throw ArgumentError('The catalog needs at least four species.');
    }
    for (final band in DifficultyBand.values) {
      final bandSize = entries
          .where((entry) => entry.difficulty == band)
          .length;
      if (bandSize < 4) {
        throw ArgumentError(
          'Each difficulty band needs at least four catalog entries.',
        );
      }
    }
    return entries;
  }

  static List<GameCatalogEntry> _buildSequence(
    List<GameCatalogEntry> catalog,
    int seed,
  ) {
    final sequence = <GameCatalogEntry>[];
    for (final band in DifficultyBand.values) {
      final bandEntries =
          catalog.where((entry) => entry.difficulty == band).toList()
            ..shuffle(Random(seed ^ (band.index * 0x9E3779B9)));
      sequence.addAll(bandEntries);
    }
    return List.unmodifiable(sequence);
  }
}
