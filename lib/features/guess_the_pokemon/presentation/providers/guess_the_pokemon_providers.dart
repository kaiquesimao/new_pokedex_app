import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/entities/game_catalog_entry.dart';
import 'package:pokedex_app/features/guess_the_pokemon/domain/services/guess_the_pokemon_engine.dart';
import 'package:pokedex_app/features/guess_the_pokemon/presentation/providers/guess_the_pokemon_controller.dart';

export 'package:pokedex_app/core/providers/core_providers.dart'
    show guessThePokemonRepositoryProvider;

export 'guess_the_pokemon_controller.dart';

final guessThePokemonAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).isAuthenticated,
);

final guessThePokemonEngineProvider = Provider<GuessThePokemonEngine>((ref) {
  return GuessThePokemonEngine(
    catalog: _defaultCatalog,
    seed: Random().nextInt(1 << 32),
  );
});

final guessThePokemonLocalCatalogProvider = FutureProvider<List<GameCatalogEntry>>((ref) {
  return ref.read(guessThePokemonRepositoryProvider).loadLocalCatalog();
});

final guessThePokemonControllerProvider =
    NotifierProvider<GuessThePokemonController, GuessThePokemonState>(
      GuessThePokemonController.new,
    );

final List<GameCatalogEntry> _defaultCatalog = [
  ...List.generate(
    4,
    (index) => GameCatalogEntry(
      speciesId: index + 1,
      name: 'Pokemon ${index + 1}',
      difficulty: DifficultyBand.easy,
    ),
  ),
  ...List.generate(
    4,
    (index) => GameCatalogEntry(
      speciesId: index + 5,
      name: 'Pokemon ${index + 5}',
      difficulty: DifficultyBand.medium,
    ),
  ),
  ...List.generate(
    4,
    (index) => GameCatalogEntry(
      speciesId: index + 9,
      name: 'Pokemon ${index + 9}',
      difficulty: DifficultyBand.hard,
    ),
  ),
];
