import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/repositories/guess_the_pokemon_repository.dart';

enum LeaderboardStatus { idle, loading, loaded, error }

class const LeaderboardState({
  final LeaderboardStatus status = LeaderboardStatus.idle,
  final LeaderboardScope scope = LeaderboardScope.general,
  final List<LeaderboardEntryModel> entries = const [],
  final String? nextCursor,
  final Object? error,
  final bool isLoadingMore = false,
}) {
  bool get hasMore => nextCursor != null;

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    LeaderboardScope? scope,
    List<LeaderboardEntryModel>? entries,
    String? nextCursor,
    bool clearCursor = false,
    Object? error,
    bool clearError = false,
    bool? isLoadingMore,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      scope: scope ?? this.scope,
      entries: entries ?? this.entries,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      error: clearError ? null : (error ?? this.error),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class LeaderboardNotifier extends Notifier<LeaderboardState> {
  int _generation = 0;

  @override
  LeaderboardState build() => const LeaderboardState();

  Future<void> load({LeaderboardScope scope = LeaderboardScope.general}) async {
    final generation = ++_generation;
    state = LeaderboardState(status: LeaderboardStatus.loading, scope: scope);
    try {
      final page = await ref
          .read(guessThePokemonRepositoryProvider)
          .getLeaderboard(
            scope: scope,
          );
      if (generation != _generation) return;
      state = LeaderboardState(
        status: LeaderboardStatus.loaded,
        scope: scope,
        entries: page.entries,
        nextCursor: page.nextCursor,
      );
    } on Object catch (error) {
      if (generation != _generation) return;
      state = LeaderboardState(
        status: LeaderboardStatus.error,
        scope: scope,
        error: error,
      );
    }
  }

  Future<void> loadMore() async {
    final generation = _generation;
    final scope = state.scope;
    final cursor = state.nextCursor;
    if (cursor == null || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await ref
          .read(guessThePokemonRepositoryProvider)
          .getLeaderboard(
            scope: scope,
            cursor: cursor,
          );
      if (generation != _generation || scope != state.scope) return;
      state = state.copyWith(
        status: LeaderboardStatus.loaded,
        entries: [...state.entries, ...page.entries],
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        clearError: true,
        isLoadingMore: false,
      );
    } on Object catch (error) {
      if (generation != _generation || scope != state.scope) return;
      state = state.copyWith(error: error, isLoadingMore: false);
    }
  }
}

final leaderboardProvider =
    NotifierProvider<LeaderboardNotifier, LeaderboardState>(
      LeaderboardNotifier.new,
    );
