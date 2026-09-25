import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/repositories/guess_the_pokemon_repository.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/pages/leaderboard_page.dart';

import '../../../../helpers/firebase_test_overrides.dart';
import '../../../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('shows guest guidance and highlights the current user', (
    tester,
  ) async {
    final repository = _FakeLeaderboardRepository();
    await pumpLocalizedApp(
      tester,
      child: const LeaderboardPage(),
      overrides: [
        firebaseUnavailableOverride,
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(
            isInitialized: true,
            isAuthenticated: true,
          ),
        ),
        guessThePokemonRepositoryProvider.overrideWithValue(repository),
      ],
    );

    expect(find.text('Ash'), findsOneWidget);
    expect(find.text('Você'), findsOneWidget);
  });

  testWidgets('shows sign-in guidance to a real guest', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: const LeaderboardPage(),
      overrides: [
        firebaseUnavailableOverride,
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(isInitialized: true),
        ),
        guessThePokemonRepositoryProvider.overrideWithValue(
          _FakeLeaderboardRepository(currentUser: false),
        ),
      ],
    );

    expect(
      find.text(
        'Entre para publicar sua pontuação e aparecer com seu nome de treinador.',
      ),
      findsOneWidget,
    );
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Você'), findsNothing);
  });
}

class _FakeLeaderboardRepository implements GuessThePokemonRepository {
  new({this.currentUser = true});

  final bool currentUser;

  @override
  Future<LeaderboardPageModel> getLeaderboard({
    LeaderboardScope scope = LeaderboardScope.general,
    String? cursor,
  }) async => LeaderboardPageModel(
    entries: [
      LeaderboardEntryModel(
        playerName: 'Ash',
        score: 10,
        completedAt: DateTime.utc(2026, 9, 17),
        isCurrentUser: currentUser,
      ),
    ],
  );

  @override
  Future<GameSessionModel> startSession() => throw UnimplementedError();

  @override
  Future<AnswerResultModel> submitAnswer(AnswerSubmissionModel submission) =>
      throw UnimplementedError();

  @override
  Future<PublicationStateModel> publishScore(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<int> getBestScore() => throw UnimplementedError();

  @override
  Future<void> saveBestScore(int score) => throw UnimplementedError();

  @override
  Future<bool> getPublicProfilePreference() async => false;

  @override
  Future<void> savePublicProfilePreference({required bool value, String? displayName}) async {}

  @override
  Future<List<GameCatalogEntry>> loadLocalCatalog() => throw UnimplementedError();

  @override
  Future<void> savePublicationState(PublicationStateModel state) async {}

  @override
  Future<GameSessionModel?> readCachedSession() => throw UnimplementedError();

  @override
  Future<PublicationStateModel?> readCachedPublicationState() =>
      throw UnimplementedError();
}
