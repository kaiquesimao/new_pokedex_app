import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/constants/pokemon_sprite_urls.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_round.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_session.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/repositories/guess_the_pokemon_repository.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/services/guess_the_pokemon_engine.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/providers/guess_the_pokemon_providers.dart';

enum GuessThePokemonStatus {
  idle,
  loading,
  playing,
  answering,
  finished,
  ranking,
  error,
}

@immutable
class GuessThePokemonState {
  const GuessThePokemonState({
    this.status = GuessThePokemonStatus.idle,
    this.localRound,
    this.remoteRound,
    this.score = 0,
    this.bestScore = 0,
    this.isRemote = false,
    this.sessionId,
    this.publicationState = PublicationState.notPublished,
    this.error,
    this.pendingSubmission,
    this.selectedOptionId,
    this.lastAnswerCorrect,
    this.revealedPokemonName,
    this.revealedSpriteUrl,
  });

  final GuessThePokemonStatus status;
  final GameRound? localRound;
  final GameRoundModel? remoteRound;
  final int score;
  final int bestScore;
  final bool isRemote;
  final String? sessionId;
  final PublicationState publicationState;
  final Object? error;
  final AnswerSubmissionModel? pendingSubmission;
  final int? selectedOptionId;
  final bool? lastAnswerCorrect;
  final String? revealedPokemonName;
  final String? revealedSpriteUrl;

  GameRound? get round => localRound;

  bool get canPublish =>
      isRemote &&
      sessionId != null &&
      status == GuessThePokemonStatus.finished &&
      publicationState != PublicationState.published;

  GuessThePokemonState copyWith({
    GuessThePokemonStatus? status,
    GameRound? localRound,
    bool clearLocalRound = false,
    GameRoundModel? remoteRound,
    bool clearRemoteRound = false,
    int? score,
    int? bestScore,
    bool? isRemote,
    String? sessionId,
    bool clearSessionId = false,
    PublicationState? publicationState,
    Object? error,
    bool clearError = false,
    AnswerSubmissionModel? pendingSubmission,
    bool clearPendingSubmission = false,
    int? selectedOptionId,
    bool clearSelectedOptionId = false,
    bool? lastAnswerCorrect,
    bool clearLastAnswerCorrect = false,
    String? revealedPokemonName,
    bool clearRevealedPokemonName = false,
    String? revealedSpriteUrl,
    bool clearRevealedSpriteUrl = false,
  }) {
    return GuessThePokemonState(
      status: status ?? this.status,
      localRound: clearLocalRound ? null : (localRound ?? this.localRound),
      remoteRound: clearRemoteRound ? null : (remoteRound ?? this.remoteRound),
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      isRemote: isRemote ?? this.isRemote,
      sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
      publicationState: publicationState ?? this.publicationState,
      error: clearError ? null : (error ?? this.error),
      pendingSubmission: clearPendingSubmission
          ? null
          : (pendingSubmission ?? this.pendingSubmission),
      selectedOptionId: clearSelectedOptionId
          ? null
          : (selectedOptionId ?? this.selectedOptionId),
      lastAnswerCorrect: clearLastAnswerCorrect
          ? null
          : (lastAnswerCorrect ?? this.lastAnswerCorrect),
      revealedPokemonName: clearRevealedPokemonName
          ? null
          : (revealedPokemonName ?? this.revealedPokemonName),
      revealedSpriteUrl: clearRevealedSpriteUrl
          ? null
          : (revealedSpriteUrl ?? this.revealedSpriteUrl),
    );
  }
}

class GuessThePokemonController extends Notifier<GuessThePokemonState> {
  static const _revealDelay = Duration(milliseconds: 750);

  GuessThePokemonRepository get _repository =>
      ref.read(guessThePokemonRepositoryProvider);

  GuessThePokemonEngine get _engine => ref.read(guessThePokemonEngineProvider);

  bool get _authenticated => ref.read(guessThePokemonAuthenticatedProvider);

  GameSession _localSession = GameSession();
  GuessThePokemonEngine? _activeEngine;
  var _mounted = true;
  int _generation = 0;

  @override
  GuessThePokemonState build() {
    ref.onDispose(() => _mounted = false);
    final repository = _repository;
    unawaited(_recoverPublication(repository, _generation));
    return const GuessThePokemonState();
  }

  Future<void> _recoverPublication(
    GuessThePokemonRepository repository,
    int generation,
  ) async {
    try {
      final cached = await repository.readCachedPublicationState();
      if (!_mounted ||
          cached?.sessionId == null ||
          cached!.state == PublicationState.published ||
          state.status != GuessThePokemonStatus.idle ||
          generation != _generation) {
        return;
      }
      final publicationState = cached.state == PublicationState.pending
          ? PublicationState.failed
          : cached.state;
      if (cached.state == PublicationState.pending) {
        try {
          await repository.savePublicationState(
            PublicationStateModel(
              state: publicationState,
              sessionId: cached.sessionId,
              score: cached.score,
            ),
          );
        } on Object {
          // The in-memory state remains actionable if persistence is unavailable.
        }
        if (!_mounted ||
            generation != _generation ||
            state.status != GuessThePokemonStatus.idle) {
          return;
        }
      }
      state = GuessThePokemonState(
        status: GuessThePokemonStatus.finished,
        isRemote: true,
        sessionId: cached.sessionId,
        score: cached.score,
        publicationState: publicationState,
      );
    } on Object {
      // A missing local recovery record is equivalent to an idle game.
    }
  }

  Future<void> start() async {
    final generation = ++_generation;
    state = const GuessThePokemonState(status: GuessThePokemonStatus.loading);
    try {
      if (_authenticated) {
        try {
          await _ensurePublicRankingProfile();
          if (!_isCurrent(generation)) return;
          final session = await _repository.startSession();
          if (!_isCurrent(generation)) return;
          final bestScore = await _repository.getBestScore();
          if (!_isCurrent(generation)) return;
          state = GuessThePokemonState(
            status: GuessThePokemonStatus.playing,
            remoteRound: session.round,
            bestScore: bestScore,
            isRemote: true,
            sessionId: session.sessionId,
          );
          return;
        } on Object {
          if (!_isCurrent(generation)) return;
        }
      }
      await _startLocal(generation);
    } on Object catch (error) {
      if (!_isCurrent(generation)) return;
      state = GuessThePokemonState(
        status: GuessThePokemonStatus.error,
        error: error,
      );
    }
  }

  Future<void> selectAnswer(int optionId) async {
    if (state.status != GuessThePokemonStatus.playing) return;
    final generation = _generation;
    final preview = _previewAnswer(optionId);
    state = state.copyWith(
      status: GuessThePokemonStatus.answering,
      selectedOptionId: optionId,
      lastAnswerCorrect: preview.correct,
      revealedPokemonName: preview.name,
      revealedSpriteUrl: preview.spriteUrl,
      clearError: true,
    );

    if (state.isRemote) {
      final round = state.remoteRound;
      if (round == null) return;
      try {
        final startedAt = DateTime.now();
        final result = await _repository.submitAnswer(
          AnswerSubmissionModel(
            sessionId: state.sessionId!,
            roundIndex: round.roundIndex,
            optionId: optionId,
          ),
        );
        if (!_isCurrent(generation)) return;
        final serverName = result.correctPokemonName?.trim();
        final serverSprite = result.correctSpriteUrl;
        state = state.copyWith(
          lastAnswerCorrect: result.correct,
          revealedPokemonName:
              (serverName != null && serverName.isNotEmpty)
                  ? serverName
                  : state.revealedPokemonName,
          revealedSpriteUrl: serverSprite == null || serverSprite.isEmpty
              ? state.revealedSpriteUrl
              : PokemonSpriteUrls.highQualitySpriteUrl(
                  serverSprite,
                  speciesId: PokemonSpriteUrls.idFromSpriteUrl(serverSprite),
                ),
        );
        await _holdRevealRemaining(startedAt, generation);
        if (!_isCurrent(generation)) return;
        await _applyRemoteResult(result, generation, keepReveal: result.finished);
      } on Object catch (error) {
        if (!_isCurrent(generation)) return;
        state = state.copyWith(
          status: GuessThePokemonStatus.error,
          error: error,
          pendingSubmission: AnswerSubmissionModel(
            sessionId: state.sessionId!,
            roundIndex: round.roundIndex,
            optionId: optionId,
          ),
        );
      }
      return;
    }

    final round = state.localRound;
    if (round != null) {
      final startedAt = DateTime.now();
      await _holdRevealRemaining(startedAt, generation);
      if (!_isCurrent(generation)) return;
      await _applyLocalResult(round, optionId, generation);
    }
  }

  Future<void> playAgain() => start();

  Future<void> retryAnswer() async {
    final submission = state.pendingSubmission;
    if (submission == null || !state.isRemote) return;
    state = state.copyWith(status: GuessThePokemonStatus.answering, clearError: true);
    try {
      final result = await _repository.submitAnswer(submission);
      await _applyRemoteResult(result, _generation, keepReveal: result.finished);
    } on Object catch (error) {
      state = state.copyWith(status: GuessThePokemonStatus.error, error: error);
    }
  }

  void abandon() {
    _generation++;
    _localSession = _engine.startSession();
    state = const GuessThePokemonState();
  }

  Future<void> retryPublication() async {
    if (!state.canPublish) return;
    final generation = _generation;
    state = state.copyWith(publicationState: PublicationState.pending);
    try {
      final publication = await _repository.publishScore(state.sessionId!);
      if (!_isCurrent(generation)) return;
      final saved = PublicationStateModel(
        state: publication.state,
        publishedAt: publication.publishedAt,
        sessionId: state.sessionId,
        score: state.score,
      );
      await _repository.savePublicationState(saved);
      if (!_isCurrent(generation)) return;
      state = state.copyWith(publicationState: publication.state);
    } on Object catch (error) {
      if (!_isCurrent(generation)) return;
      state = state.copyWith(
        publicationState: PublicationState.failed,
        error: error,
      );
      await _repository.savePublicationState(
        PublicationStateModel(
          state: PublicationState.failed,
          sessionId: state.sessionId,
          score: state.score,
        ),
      );
    }
  }

  Future<void> _startLocal(int generation) async {
    final catalog = await ref.read(guessThePokemonLocalCatalogProvider.future);
    _activeEngine = GuessThePokemonEngine(catalog: catalog, seed: 42);
    _localSession = _activeEngine!.startSession();
    final round = _activeEngine!.nextRound(_localSession);
    final bestScore = await _repository.getBestScore();
    if (!_isCurrent(generation)) return;
    state = GuessThePokemonState(
      status: GuessThePokemonStatus.playing,
      localRound: round,
      bestScore: bestScore,
    );
  }

  Future<void> _applyRemoteResult(
    AnswerResultModel result,
    int generation, {
    bool keepReveal = false,
  }) async {
    final bestScore = result.score > state.bestScore
        ? result.score
        : state.bestScore;
    if (result.score > state.bestScore) {
      await _repository.saveBestScore(result.score);
      if (!_isCurrent(generation)) return;
    }
    if (!_isCurrent(generation)) return;
    if (result.finished) {
      state = state.copyWith(
        status: GuessThePokemonStatus.finished,
        score: result.score,
        bestScore: bestScore,
        lastAnswerCorrect: result.correct,
        revealedPokemonName: keepReveal ? state.revealedPokemonName : state.revealedPokemonName,
        revealedSpriteUrl: keepReveal ? state.revealedSpriteUrl : state.revealedSpriteUrl,
      );
      await _repository.savePublicationState(
        PublicationStateModel(
          state: PublicationState.pending,
          sessionId: state.sessionId,
          score: result.score,
        ),
      );
      await retryPublication();
      return;
    }
    if (result.correct && result.nextRound != null) {
      state = state.copyWith(
        status: GuessThePokemonStatus.playing,
        remoteRound: result.nextRound,
        score: result.score,
        bestScore: bestScore,
        clearSelectedOptionId: true,
        clearLastAnswerCorrect: true,
        clearRevealedPokemonName: true,
        clearRevealedSpriteUrl: true,
      );
      return;
    }
    state = state.copyWith(
      status: GuessThePokemonStatus.error,
      error: StateError('The server did not provide the next round.'),
    );
  }

  Future<void> _applyLocalResult(
    GameRound round,
    int optionId,
    int generation,
  ) async {
    final selected = round.options.firstWhere(
      (option) => option.speciesId == optionId,
    );
    final engine = _activeEngine ?? _engine;
    final result = engine.answer(_localSession, round, selected);
    _localSession = result.session;
    final bestScore = result.session.score > state.bestScore
        ? result.session.score
        : state.bestScore;
    if (result.session.score > state.bestScore) {
      await _repository.saveBestScore(result.session.score);
      if (!_isCurrent(generation)) return;
    }
    if (!_isCurrent(generation)) return;
    if (result.session.isFinished || !engine.hasNextRound(_localSession)) {
      state = state.copyWith(
        status: GuessThePokemonStatus.finished,
        localRound: round,
        score: result.session.score,
        bestScore: bestScore,
        lastAnswerCorrect: result.isCorrect,
        revealedPokemonName: round.correctAnswer.name,
        revealedSpriteUrl: round.correctAnswer.spriteUrl,
      );
      return;
    }
    state = state.copyWith(
      status: GuessThePokemonStatus.playing,
      localRound: engine.nextRound(_localSession),
      score: result.session.score,
      bestScore: bestScore,
      clearSelectedOptionId: true,
      clearLastAnswerCorrect: true,
      clearRevealedPokemonName: true,
      clearRevealedSpriteUrl: true,
    );
  }

  Future<void> _holdRevealRemaining(DateTime startedAt, int generation) async {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _revealDelay - elapsed;
    if (remaining <= Duration.zero) return;
    await Future<void>.delayed(remaining);
    if (!_isCurrent(generation)) return;
  }

  Future<void> _ensurePublicRankingProfile() async {
    final auth = ref.read(authProvider);
    final displayName = auth.displayName?.trim();
    await _repository.savePublicProfilePreference(
      value: true,
      displayName: (displayName == null || displayName.isEmpty)
          ? null
          : displayName,
    );
  }

  ({bool correct, String name, String? spriteUrl}) _previewAnswer(int optionId) {
    final local = state.localRound;
    if (local != null) {
      final sprite = PokemonSpriteUrls.highQualitySpriteUrl(
        local.correctAnswer.spriteUrl ?? '',
        speciesId: local.correctAnswer.speciesId,
      );
      return (
        correct: local.correctAnswer.speciesId == optionId,
        name: local.correctAnswer.name,
        spriteUrl: sprite.isEmpty ? local.correctAnswer.spriteUrl : sprite,
      );
    }

    final remote = state.remoteRound;
    if (remote == null) {
      return (correct: false, name: '', spriteUrl: null);
    }
    final silhouette = remote.silhouetteUrl ?? '';
    final targetId =
        PokemonSpriteUrls.idFromSpriteUrl(silhouette) ??
        remote.options
            .where((option) => option.spriteUrl == silhouette)
            .map((option) => option.id)
            .firstOrNull;
    final correctOption = remote.options
        .where((option) => option.id == targetId)
        .firstOrNull;
    final name = correctOption?.name ?? '';
    final sprite = PokemonSpriteUrls.highQualitySpriteUrl(
      silhouette.isEmpty ? (correctOption?.spriteUrl ?? '') : silhouette,
      speciesId: targetId,
    );
    return (
      correct: targetId != null && targetId == optionId,
      name: name,
      spriteUrl: sprite.isEmpty ? silhouette : sprite,
    );
  }

  bool _isCurrent(int generation) => generation == _generation;
}
