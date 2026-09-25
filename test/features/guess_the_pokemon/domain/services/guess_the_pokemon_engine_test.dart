import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/services/guess_the_pokemon_engine.dart';

void main() {
  final catalog = <GameCatalogEntry>[
    ...List.generate(
      4,
      (index) => GameCatalogEntry(
        speciesId: index + 1,
        name: 'Easy ${index + 1}',
        difficulty: DifficultyBand.easy,
      ),
    ),
    ...List.generate(
      4,
      (index) => GameCatalogEntry(
        speciesId: index + 5,
        name: 'Medium ${index + 5}',
        difficulty: DifficultyBand.medium,
      ),
    ),
    ...List.generate(
      4,
      (index) => GameCatalogEntry(
        speciesId: index + 9,
        name: 'Hard ${index + 9}',
        difficulty: DifficultyBand.hard,
      ),
    ),
  ];

  test('different seeds produce different species sequences', () {
    final first = GuessThePokemonEngine(catalog: catalog, seed: 1);
    final second = GuessThePokemonEngine(catalog: catalog, seed: 2);

    expect(
      first.nextRound(first.startSession()).correctAnswer.speciesId,
      isNot(second.nextRound(second.startSession()).correctAnswer.speciesId),
    );
  });

  test('uses the same seeded sequence and options for two engines', () {
    final first = GuessThePokemonEngine(catalog: catalog, seed: 42);
    final second = GuessThePokemonEngine(catalog: catalog, seed: 42);
    var firstSession = first.startSession();
    var secondSession = second.startSession();

    for (var index = 0; index < 3; index++) {
      final firstRound = first.nextRound(firstSession);
      final secondRound = second.nextRound(secondSession);

      expect(firstRound, secondRound);
      firstSession = first
          .answer(
            firstSession,
            firstRound,
            firstRound.correctAnswer,
          )
          .session;
      secondSession = second
          .answer(
            secondSession,
            secondRound,
            secondRound.correctAnswer,
          )
          .session;
    }
  });

  test('creates four unique options in the target difficulty band', () {
    final engine = GuessThePokemonEngine(catalog: catalog, seed: 7);
    final round = engine.nextRound(engine.startSession());

    expect(round.options, hasLength(4));
    expect(
      round.options.map((option) => option.speciesId).toSet(),
      hasLength(4),
    );
    expect(round.options, contains(round.correctAnswer));
    expect(
      round.options.every(
        (option) => option.difficulty == round.difficulty,
      ),
      isTrue,
    );
  });

  test('progresses through difficulty bands as the round index increases', () {
    final engine = GuessThePokemonEngine(catalog: catalog, seed: 7);
    var session = engine.startSession();

    for (var index = 0; index < catalog.length; index++) {
      final round = engine.nextRound(session);
      final expectedBand = DifficultyBand.values[index ~/ 4];

      expect(round.difficulty, expectedBand);
      session = engine.answer(session, round, round.correctAnswer).session;
    }
  });

  test('rejects a catalog without four entries in every difficulty band', () {
    final incompleteCatalog = catalog
        .where((entry) => entry.difficulty != DifficultyBand.hard)
        .toList();

    expect(
      () => GuessThePokemonEngine(catalog: incompleteCatalog, seed: 7),
      throwsArgumentError,
    );
  });

  test('awards one point for correct answers and continues the session', () {
    final engine = GuessThePokemonEngine(catalog: catalog, seed: 12);
    final session = engine.startSession();
    final round = engine.nextRound(session);

    final result = engine.answer(session, round, round.correctAnswer);

    expect(result.isCorrect, isTrue);
    expect(result.pointsAwarded, 1);
    expect(result.session.score, 1);
    expect(result.session.isFinished, isFalse);
    expect(result.session.rounds, [round]);
  });

  test('finishes on the first wrong answer without awarding a point', () {
    final engine = GuessThePokemonEngine(catalog: catalog, seed: 12);
    final session = engine.startSession();
    final round = engine.nextRound(session);
    final wrongAnswer = round.options.firstWhere(
      (option) => option != round.correctAnswer,
    );

    final result = engine.answer(session, round, wrongAnswer);

    expect(result.isCorrect, isFalse);
    expect(result.pointsAwarded, 0);
    expect(result.session.score, 0);
    expect(result.session.isFinished, isTrue);
    expect(result.session.rounds, [round]);
  });

  test('does not repeat a species across correctly answered rounds', () {
    final engine = GuessThePokemonEngine(catalog: catalog, seed: 99);
    var session = engine.startSession();
    final seenSpecies = <int>{};

    for (var index = 0; index < 6; index++) {
      final round = engine.nextRound(session);
      expect(seenSpecies.add(round.correctAnswer.speciesId), isTrue);
      session = engine.answer(session, round, round.correctAnswer).session;
    }
  });
}
