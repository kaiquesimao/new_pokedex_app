import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/mappers/guess_the_pokemon_mapper.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_result.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_round.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_session.dart';

void main() {
  test(
    'deserializes the shared Worker fixture without a correct answer field',
    () {
      final contract = jsonDecode(
        File('cloudflare/guess-the-pokemon/fixtures/game-contract.json')
            .readAsStringSync(),
      ) as Map<String, dynamic>;
      final sessionJson = Map<String, dynamic>.from(
        contract['session'] as Map,
      );
      final answerJson = Map<String, dynamic>.from(
        contract['answer'] as Map,
      );
      final session = GameSessionModel.fromJson(sessionJson);
      final answer = AnswerResultModel.fromJson(answerJson);

      expect(session.sessionId, 'fixture-session');
      expect(session.round.options, hasLength(4));
      expect(answer.correct, isTrue);
      expect(answer.score, 1);
      expect(answer.nextRound, isNotNull);
      expect(session.round.toJson(), isNot(contains('isTarget')));
      expect(session.round.toJson(), isNot(contains('correct_species_id')));
    },
  );

  test('round-trip models preserve immutable game data', () {
    final session = GameSessionModel(
      sessionId: 'session-1',
      catalogVersion: 'v1',
      round: GameRoundModel(
        roundIndex: 1,
        options: const [
          GameRoundOptionModel(id: 25, name: 'Pikachu'),
          GameRoundOptionModel(id: 4, name: 'Charmander'),
        ],
      ),
    );

    final decoded = GameSessionModel.fromJson(session.toJson());

    expect(decoded, session);
    expect(
      () => session.round.options.add(session.round.options.first),
      throwsUnsupportedError,
    );
  });

  test('answer result uses the server score and has no client score input', () {
    final result = AnswerResultModel.fromJson(const {
      'correct': true,
      'finished': false,
      'score': 42,
    });

    expect(result.score, 42);
    expect(result.correct, isTrue);
    expect(
      const AnswerSubmissionModel(
        sessionId: 'session-1',
        roundIndex: 1,
        optionId: 25,
      ).toJson(),
      {
        'roundIndex': 1,
        'optionId': 25,
      },
    );
  });

  test('remote round never serializes or requires the correct target', () {
    final round = GameRoundModel.fromJson(const {
      'roundIndex': 0,
      'options': [
        {'id': 25, 'label': 'Pikachu', 'spriteUrl': 'sprite.png'},
      ],
    });

    expect(round.toJson(), isNot(contains('correct_species_id')));
    expect(round.toJson(), isNot(contains('correctSpeciesId')));
    expect(
      () => GameRoundModel.fromJson(const {
        'roundIndex': 0,
        'correct_species_id': 25,
        'options': <dynamic>[],
      }),
      returnsNormally,
    );
  });

  test('maps leaderboard models to Task 1 domain entities', () {
    final entry = LeaderboardEntryModel(
      playerName: 'Ash',
      score: 3,
      completedAt: DateTime.utc(2026, 9, 17),
    ).toDomain();

    expect(entry.playerName, 'Ash');
  });

  test('maps the backend current-user marker without identity fields', () {
    final page = LeaderboardPageModel.fromJson(const {
      'entries': [
        {
          'player_name': 'Ash',
          'rank': 7,
          'score': 10,
          'completed_at': '2026-09-17T00:00:00.000Z',
          'is_current_user': true,
        },
      ],
    });

    expect(page.entries.single.isCurrentUser, isTrue);
    expect(page.entries.single.playerName, 'Ash');
    expect(page.entries.single.rank, 7);
  });

  test('maps an answer result to GameResult with server values', () {
    final result =
        const AnswerResultModel(
          correct: true,
          score: 8,
          finished: false,
        ).toDomain(
          round: GameRound(
            sequenceNumber: 1,
            correctAnswer: const GameCatalogEntry(
              speciesId: 25,
              name: 'Pikachu',
              difficulty: DifficultyBand.easy,
            ),
            options: const [],
          ),
          session: GameSession(score: 8),
        );

    expect(result, isA<GameResult>());
    expect(result.pointsAwarded, 1);
    expect(result.isCorrect, isTrue);
  });
}
