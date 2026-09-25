import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/datasources/guess_the_pokemon_local_datasource.dart';
import 'package:pokedex_app/features/guess_the_pokemon/data/models/game_api_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores and reads a session and publication state', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final local = GuessThePokemonLocalDataSource(prefs);
    final session = GameSessionModel(
      sessionId: 'session-1',
      catalogVersion: 'v1',
      round: GameRoundModel(roundIndex: 0, options: const []),
    );

    await local.saveSession(session);
    await local.savePublicationState(
      const PublicationStateModel(state: PublicationState.pending),
    );

    expect(await local.readSession(), session);
    expect(
      await local.readPublicationState(),
      const PublicationStateModel(state: PublicationState.pending),
    );
  });

  test('ignores malformed cached data', () async {
    SharedPreferences.setMockInitialValues({
      'guess_the_pokemon_session:guest': '{not-json',
      'guess_the_pokemon_publication:guest': '{"state":"unknown"}',
    });
    final prefs = await SharedPreferences.getInstance();
    final local = GuessThePokemonLocalDataSource(prefs);

    expect(await local.readSession(), isNull);
    expect(await local.readPublicationState(), isNull);
  });

  test('stores best score and public profile preference', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final local = GuessThePokemonLocalDataSource(prefs);

    expect(await local.getBestScore(), 0);
    expect(await local.getPublicProfilePreference(), isFalse);

    await local.saveBestScore(12);
    await local.savePublicProfilePreference(value: true);

    expect(await local.getBestScore(), 12);
    expect(await local.getPublicProfilePreference(), isTrue);
  });

  test('loads the versioned Worker catalog for offline play', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final catalog = await GuessThePokemonLocalDataSource(prefs).loadCatalog();

    expect(catalog, hasLength(1025));
    expect(catalog.every((entry) => entry.spriteUrl?.isNotEmpty ?? false), isTrue);
    expect(catalog.map((entry) => entry.speciesId).toSet(), hasLength(1025));
  });

  test('does not recover another authenticated user or guest state', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final userOne = GuessThePokemonLocalDataSource(prefs, scopeKey: 'uid-1');
    final userTwo = GuessThePokemonLocalDataSource(prefs, scopeKey: 'uid-2');
    final guest = GuessThePokemonLocalDataSource(prefs);
    const publication = PublicationStateModel(
      state: PublicationState.failed,
      sessionId: 'session-1',
      score: 3,
    );

    await userOne.savePublicationState(publication);
    await userOne.saveSession(
      GameSessionModel(
        sessionId: 'session-1',
        catalogVersion: 'v1',
        round: GameRoundModel(roundIndex: 0, options: const []),
      ),
    );

    expect(await userTwo.readPublicationState(), isNull);
    expect(await userTwo.readSession(), isNull);
    expect(await guest.readPublicationState(), isNull);
    expect(await guest.readSession(), isNull);
  });
}
