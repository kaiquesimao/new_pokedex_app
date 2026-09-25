import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_round.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/pages/guess_the_pokemon_page.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/providers/guess_the_pokemon_providers.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/widgets/game_option_button.dart';
import 'package:pokedex_app/l10n/app_localization_delegates.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/pokemon_sprite_image.dart';

void main() {
  testWidgets(
    'idle page explains guest play and starts through the controller',
    (
      tester,
    ) async {
      final controller = _FakeController(const GuessThePokemonState());
      await _pump(tester, controller);

      expect(find.text('Quem é esse Pokémon?'), findsOneWidget);
      expect(find.text('Jogar como convidado'), findsOneWidget);

      await tester.tap(find.text('Começar partida'));
      expect(controller.startCalls, 1);
    },
  );

  testWidgets('idle page opens the leaderboard route', (tester) async {
    final controller = _FakeController(const GuessThePokemonState());
    await _pump(tester, controller);

    await tester.tap(find.text('Ver ranking'));
    await tester.pumpAndSettle();

    expect(find.text('Ranking'), findsOneWidget);
  });

  testWidgets(
    'playing page renders four semantic answer buttons and a sprite',
    (
      tester,
    ) async {
      final round = GameRound(
        sequenceNumber: 1,
        correctAnswer: const GameCatalogEntry(
          speciesId: 25,
          name: 'Pikachu',
          difficulty: DifficultyBand.easy,
          spriteUrl: 'https://example.com/pikachu.png',
        ),
        options: const [
          GameCatalogEntry(
            speciesId: 25,
            name: 'Pikachu',
            difficulty: DifficultyBand.easy,
            spriteUrl: 'https://example.com/pikachu.png',
          ),
          GameCatalogEntry(
            speciesId: 1,
            name: 'Bulbasaur',
            difficulty: DifficultyBand.easy,
          ),
          GameCatalogEntry(
            speciesId: 4,
            name: 'Charmander',
            difficulty: DifficultyBand.easy,
          ),
          GameCatalogEntry(
            speciesId: 7,
            name: 'Squirtle',
            difficulty: DifficultyBand.easy,
          ),
        ],
      );
      final controller = _FakeController(
        GuessThePokemonState(
          localRound: round,
          status: GuessThePokemonStatus.playing,
          spriteReady: true,
        ),
      );
      await _pump(tester, controller);

      expect(find.bySemanticsLabel('Resposta Pikachu'), findsOneWidget);
      expect(find.bySemanticsLabel('Resposta Bulbasaur'), findsOneWidget);
      expect(find.bySemanticsLabel('Resposta Charmander'), findsOneWidget);
      expect(find.bySemanticsLabel('Resposta Squirtle'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(4));
      expect(find.byType(PokemonSpriteImage), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Resposta Pikachu'));
      expect(controller.selectedAnswer, 25);
    },
  );

  testWidgets('finished page exposes score and play again', (tester) async {
    final controller = _FakeController(
      const GuessThePokemonState(
        status: GuessThePokemonStatus.finished,
        score: 3,
        bestScore: 5,
      ),
    );
    await _pump(tester, controller);

    expect(find.text('Resultado da partida'), findsOneWidget);
    expect(find.text('3 pontos'), findsOneWidget);
    expect(find.text('Jogar novamente'), findsOneWidget);

    await tester.tap(find.text('Jogar novamente'));
    expect(controller.playAgainCalls, 1);
  });

  testWidgets('finished page opens the leaderboard route', (tester) async {
    final controller = _FakeController(
      const GuessThePokemonState(
        status: GuessThePokemonStatus.finished,
        score: 3,
        bestScore: 5,
      ),
    );
    await _pump(tester, controller);

    await tester.tap(find.text('Ver ranking'));
    await tester.pumpAndSettle();

    expect(find.text('Ranking'), findsOneWidget);
  });

  testWidgets('abandon action requires confirmation', (tester) async {
    final round = GameRound(
      sequenceNumber: 1,
      correctAnswer: const GameCatalogEntry(
        speciesId: 25,
        name: 'Pikachu',
        difficulty: DifficultyBand.easy,
      ),
      options: const [
        GameCatalogEntry(
          speciesId: 25,
          name: 'Pikachu',
          difficulty: DifficultyBand.easy,
        ),
        GameCatalogEntry(
          speciesId: 1,
          name: 'Bulbasaur',
          difficulty: DifficultyBand.easy,
        ),
        GameCatalogEntry(
          speciesId: 4,
          name: 'Charmander',
          difficulty: DifficultyBand.easy,
        ),
        GameCatalogEntry(
          speciesId: 7,
          name: 'Squirtle',
          difficulty: DifficultyBand.easy,
        ),
      ],
    );
    final controller = _FakeController(
      GuessThePokemonState(
        localRound: round,
        status: GuessThePokemonStatus.playing,
      ),
    );
    await _pump(tester, controller);

    await tester.tap(find.byTooltip('Abandonar partida'));
    await tester.pump();
    expect(find.text('Sair da partida?'), findsOneWidget);
    expect(controller.abandonCalls, 0);

    await tester.tap(find.text('Sair da partida'));
    expect(controller.abandonCalls, 1);
  });

  testWidgets('pending publication shows progress without retry action', (
    tester,
  ) async {
    final controller = _FakeController(
      const GuessThePokemonState(
        status: GuessThePokemonStatus.finished,
        score: 4,
        isRemote: true,
        sessionId: 'session',
        publicationState: PublicationState.pending,
      ),
    );
    await _pump(tester, controller);

    expect(find.text('Publicando pontuação...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Tentar publicar novamente'), findsNothing);
  });

  testWidgets('failed publication shows error and retries through controller', (
    tester,
  ) async {
    final controller = _FakeController(
      const GuessThePokemonState(
        status: GuessThePokemonStatus.finished,
        score: 4,
        isRemote: true,
        sessionId: 'session',
        publicationState: PublicationState.failed,
      ),
    );
    await _pump(tester, controller);

    expect(find.text('Não foi possível publicar a pontuação.'), findsOneWidget);
    expect(find.text('Tentar publicar novamente'), findsOneWidget);

    await tester.tap(find.text('Tentar publicar novamente'));
    expect(controller.retryPublicationCalls, 1);
  });

  testWidgets('large text keeps answer controls within a narrow viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    tester.platformDispatcher.textScaleFactorTestValue = 2.5;
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    final controller = _FakeController(
      GuessThePokemonState(
        status: GuessThePokemonStatus.playing,
        spriteReady: true,
        localRound: _roundWithLongNames(),
      ),
    );
    await _pump(tester, controller);

    expect(find.byType(GameOptionButton), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide viewport lays out answer controls in two columns', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = _FakeController(
      GuessThePokemonState(
        status: GuessThePokemonStatus.playing,
        spriteReady: true,
        localRound: _roundWithLongNames(),
      ),
    );
    await _pump(tester, controller);

    final first = tester.getTopLeft(find.byType(GameOptionButton).first);
    final third = tester.getTopLeft(find.byType(GameOptionButton).at(2));
    expect(first.dy, lessThan(third.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('answer buttons remain keyboard focusable in traversal order', (
    tester,
  ) async {
    final controller = _FakeController(
      GuessThePokemonState(
        status: GuessThePokemonStatus.playing,
        spriteReady: true,
        localRound: _roundWithLongNames(),
      ),
    );
    await _pump(tester, controller);

    await tester.tap(
      find.bySemanticsLabel(
        'Resposta Bulbasaur with a very long translated display name',
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    final firstFocused = FocusManager.instance.primaryFocus?.context;
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    final secondFocused = FocusManager.instance.primaryFocus?.context;

    expect(firstFocused, isNotNull);
    expect(secondFocused, isNotNull);
    expect(firstFocused, isNot(same(secondFocused)));
  });
}

GameRound _roundWithLongNames() {
  return GameRound(
    sequenceNumber: 1,
    correctAnswer: const GameCatalogEntry(
      speciesId: 25,
      name: 'Pikachu',
      difficulty: DifficultyBand.easy,
      spriteUrl: 'https://example.com/pikachu.png',
    ),
    options: const [
      GameCatalogEntry(
        speciesId: 25,
        name: 'Pikachu',
        difficulty: DifficultyBand.easy,
        spriteUrl: 'https://example.com/pikachu.png',
      ),
      GameCatalogEntry(
        speciesId: 1,
        name: 'Bulbasaur with a very long translated display name',
        difficulty: DifficultyBand.easy,
      ),
      GameCatalogEntry(
        speciesId: 4,
        name: 'Charmander with a very long translated display name',
        difficulty: DifficultyBand.easy,
      ),
      GameCatalogEntry(
        speciesId: 7,
        name: 'Squirtle with a very long translated display name',
        difficulty: DifficultyBand.easy,
      ),
    ],
  );
}

Future<void> _pump(WidgetTester tester, _FakeController controller) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        guessThePokemonControllerProvider.overrideWith(() => controller),
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(isInitialized: true),
        ),
      ],
      child: MaterialApp.router(
        locale: const Locale('pt'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: appLocalizationDelegates,
        routerConfig: GoRouter(
          initialLocation: '/game',
          routes: [
            GoRoute(
              path: '/game',
              builder: (_, _) => const GuessThePokemonPage(),
            ),
            GoRoute(
              path: '/leaderboard',
              builder: (_, _) => const Scaffold(body: Text('Ranking')),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 320));
}

class _FakeController extends GuessThePokemonController {
  new(this.initialState);

  final GuessThePokemonState initialState;
  int startCalls = 0;
  int playAgainCalls = 0;
  int abandonCalls = 0;
  int retryPublicationCalls = 0;
  int? selectedAnswer;

  @override
  GuessThePokemonState build() => initialState;

  @override
  Future<void> start() async => startCalls++;

  @override
  Future<void> playAgain() async => playAgainCalls++;

  @override
  Future<void> selectAnswer(int optionId, {bool timedOut = false}) async =>
      selectedAnswer = optionId;

  @override
  Future<void> retryPublication() async => retryPublicationCalls++;

  @override
  void abandon() => abandonCalls++;
}
