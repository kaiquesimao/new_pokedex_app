import 'package:flutter/foundation.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';

enum PublicationState { notPublished, pending, published, failed }

@immutable
class GameRoundOptionModel {
  const GameRoundOptionModel({
    required this.id,
    required this.name,
    this.spriteUrl,
  });

  factory GameRoundOptionModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['label'] ?? json['name'];
    if (id is! int || name is! String) {
      throw const FormatException('Invalid game round option');
    }
    return GameRoundOptionModel(
      id: id,
      name: name,
      spriteUrl: json['spriteUrl'] as String?,
    );
  }

  final int id;
  final String name;
  final String? spriteUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (spriteUrl != null) 'spriteUrl': spriteUrl,
  };

  @override
  bool operator ==(Object other) =>
      other is GameRoundOptionModel &&
      other.id == id &&
      other.name == name &&
      other.spriteUrl == spriteUrl;

  @override
  int get hashCode => Object.hash(id, name, spriteUrl);
}

@immutable
class GameRoundModel {
  new({
    required this.roundIndex,
    required List<GameRoundOptionModel> options,
    this.silhouetteUrl,
  }) : options = List.unmodifiable(options);

  factory GameRoundModel.fromJson(Map<String, dynamic> json) {
    final roundIndex = json['roundIndex'];
    final options = json['options'];
    if (roundIndex is! int || options is! List) {
      throw const FormatException('Invalid game round');
    }
    return GameRoundModel(
      roundIndex: roundIndex,
      silhouetteUrl: json['silhouetteUrl'] as String?,
      options: options
          .map(
            (option) => GameRoundOptionModel.fromJson(
              option as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  final int roundIndex;
  final List<GameRoundOptionModel> options;
  final String? silhouetteUrl;

  Map<String, dynamic> toJson() => {
    'roundIndex': roundIndex,
    if (silhouetteUrl != null) 'silhouetteUrl': silhouetteUrl,
    'options': options.map((option) => option.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      other is GameRoundModel &&
      other.roundIndex == roundIndex &&
      other.silhouetteUrl == silhouetteUrl &&
      listEquals(other.options, options);

  @override
  int get hashCode => Object.hash(roundIndex, silhouetteUrl, Object.hashAll(options));
}

@immutable
class GameSessionModel {
  new({
    required this.sessionId,
    required this.catalogVersion,
    required this.round,
  });

  factory GameSessionModel.fromJson(Map<String, dynamic> json) {
    final sessionId = json['sessionId'];
    final catalogVersion = json['catalogVersion'];
    final round = json['round'];
    if (sessionId is! String ||
        catalogVersion is! String ||
        round is! Map<String, dynamic>) {
      throw const FormatException('Invalid game session');
    }
    return GameSessionModel(
      sessionId: sessionId,
      catalogVersion: catalogVersion,
      round: GameRoundModel.fromJson(round),
    );
  }

  final String sessionId;
  final String catalogVersion;
  final GameRoundModel round;

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'catalogVersion': catalogVersion,
    'round': round.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is GameSessionModel &&
      other.sessionId == sessionId &&
      other.catalogVersion == catalogVersion &&
      other.round == round;

  @override
  int get hashCode => Object.hash(sessionId, catalogVersion, round);
}

@immutable
class AnswerSubmissionModel {
  const AnswerSubmissionModel({
    required this.sessionId,
    required this.roundIndex,
    required this.optionId,
  });

  final String sessionId;
  final int roundIndex;
  final int optionId;

  Map<String, dynamic> toJson() => {
    'roundIndex': roundIndex,
    'optionId': optionId,
  };
}

@immutable
class AnswerResultModel {
  const AnswerResultModel({
    required this.correct,
    required this.score,
    required this.finished,
    this.nextRound,
    this.correctPokemonName,
    this.correctSpriteUrl,
  });

  factory AnswerResultModel.fromJson(Map<String, dynamic> json) {
    final correct = json['correct'];
    final finished = json['finished'];
    final score = json['score'];
    if (correct is! bool || finished is! bool || score is! num) {
      throw const FormatException('Invalid game answer result');
    }
    return AnswerResultModel(
      correct: correct,
      score: score.toInt(),
      finished: finished,
      correctPokemonName: json['correctPokemonName'] as String?,
      correctSpriteUrl: json['correctSpriteUrl'] as String?,
      nextRound: json['nextRound'] is Map<String, dynamic>
          ? GameRoundModel.fromJson(json['nextRound'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool correct;
  final int score;
  final bool finished;
  final GameRoundModel? nextRound;
  final String? correctPokemonName;
  final String? correctSpriteUrl;
}

@immutable
class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.playerName,
    required this.score,
    required this.completedAt,
    this.rank = 0,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      playerName: json['player_name'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      completedAt: DateTime.parse(json['completed_at'] as String),
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      isCurrentUser: json['is_current_user'] as bool? ?? false,
    );
  }

  final String playerName;
  final int score;
  final DateTime completedAt;
  final int rank;
  final bool isCurrentUser;
}

@immutable
class LeaderboardPageModel {
  new({
    required List<LeaderboardEntryModel> entries,
    this.nextCursor,
  }) : entries = List.unmodifiable(entries);

  factory LeaderboardPageModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardPageModel(
      entries: (json['entries'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(LeaderboardEntryModel.fromJson)
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  final List<LeaderboardEntryModel> entries;
  final String? nextCursor;
}

@immutable
class PublicationStateModel {
  const PublicationStateModel({required this.state, this.publishedAt, this.sessionId, this.score = 0});

  factory PublicationStateModel.fromJson(Map<String, dynamic> json) {
    final value = json['state'];
    final state = PublicationState.values.where((item) => item.name == value);
    if (state.isEmpty) throw const FormatException('Unknown publication state');
    return PublicationStateModel(
      state: state.first,
      sessionId: json['sessionId'] as String?,
      score: json['score'] as int? ?? 0,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
    );
  }

  final PublicationState state;
  final DateTime? publishedAt;
  final String? sessionId;
  final int score;

  Map<String, dynamic> toJson() => {
    'state': state.name,
    if (sessionId != null) 'sessionId': sessionId,
    'score': score,
    if (publishedAt != null) 'published_at': publishedAt!.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is PublicationStateModel &&
      other.state == state &&
      other.sessionId == sessionId &&
      other.score == score &&
    other.publishedAt == publishedAt;

  @override
  int get hashCode => Object.hash(state, sessionId, score, publishedAt);
}

enum GuessThePokemonErrorCode {
  cache,
  network,
  api,
  serviceUnavailable,
  invalidResponse,
  notFound,
  unavailable,
}

class GuessThePokemonException implements Exception {
  const GuessThePokemonException(this.code, [this.message]);

  factory GuessThePokemonException.fromError(Object error) {
    return switch (error) {
      NetworkException() => const GuessThePokemonException(
        GuessThePokemonErrorCode.network,
      ),
      ServiceUnavailableException() => const GuessThePokemonException(
        GuessThePokemonErrorCode.serviceUnavailable,
      ),
      NotFoundException() => const GuessThePokemonException(
        GuessThePokemonErrorCode.notFound,
      ),
      ApiException() => const GuessThePokemonException(
        GuessThePokemonErrorCode.api,
      ),
      CacheException() => const GuessThePokemonException(
        GuessThePokemonErrorCode.cache,
      ),
      GameApiUnavailableException() => const GuessThePokemonException(
        GuessThePokemonErrorCode.unavailable,
      ),
      FormatException() => const GuessThePokemonException(
        GuessThePokemonErrorCode.invalidResponse,
      ),
      TypeError() => const GuessThePokemonException(
        GuessThePokemonErrorCode.invalidResponse,
      ),
      _ => GuessThePokemonException(GuessThePokemonErrorCode.api, '$error'),
    };
  }

  final GuessThePokemonErrorCode code;
  final String? message;

  @override
  String toString() => message == null
      ? 'GuessThePokemonException($code)'
      : 'GuessThePokemonException($code): $message';
}
