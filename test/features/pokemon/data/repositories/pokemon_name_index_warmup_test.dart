import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/game_text_resolver.dart';
import 'package:pokedex_app/core/locale/machine_translation_backend.dart';
import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/data/repositories/pokemon_repository_impl.dart';

void main() {
  late AppDatabase db;
  late PokemonLocalDataSource local;
  late _CountingRemote remote;
  late PokemonRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    local = PokemonLocalDataSource(db);
    remote = _CountingRemote(
      listResults: const [
        NamedApiResource(
          name: 'bulbasaur',
          url: 'https://pokeapi.co/api/v2/pokemon/1/',
        ),
        NamedApiResource(
          name: 'ivysaur',
          url: 'https://pokeapi.co/api/v2/pokemon/2/',
        ),
        NamedApiResource(
          name: 'pikachu',
          url: 'https://pokeapi.co/api/v2/pokemon/25/',
        ),
      ],
      speciesById: {
        1: _species(id: 1, en: 'Bulbasaur', pt: 'Bulbasaur'),
        2: _species(id: 2, en: 'Ivysaur', pt: 'Ivysaur'),
        25: _species(id: 25, en: 'Pikachu', pt: 'Pikachuzinho'),
      },
    );
    repository = PokemonRepositoryImpl(
      remote: remote,
      local: local,
      gameTextResolver: GameTextResolver(
        machineTranslation: _NoopMachineTranslation(),
        fetchResourceEntries: (_, _) async => const [],
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('warmPokemonNameIndex phase A uses a single list fetch and no per-id',
      () async {
    await repository.warmPokemonNameIndex();

    expect(remote.listCallCount, 1);
    expect(remote.pokemonCallCount, 0);
    expect(await repository.isNameIndexReady(), isTrue);

    final hits = await repository.searchPokemonRefsByName('pika');
    expect(hits.map((r) => r.id), [25]);
  });

  test('warm phase B fetches each species once for default-line ids', () async {
    await repository.warmPokemonNameIndex();

    expect(remote.listCallCount, 1);
    expect(remote.pokemonCallCount, 0);
    expect(remote.speciesCallCount, 3);
  });

  test('warm phase B writes localizedName searchable', () async {
    await repository.warmPokemonNameIndex();
    final hits = await repository.searchPokemonRefsByName('Pikachu');
    expect(hits.any((r) => r.id == 25), isTrue);
  });

  test(
    'warm phase B resolves forms via pokemon then cached species',
    () async {
      remote = _CountingRemote(
        listResults: const [
          NamedApiResource(
            name: 'bulbasaur',
            url: 'https://pokeapi.co/api/v2/pokemon/1/',
          ),
          NamedApiResource(
            name: 'deoxys-attack',
            url: 'https://pokeapi.co/api/v2/pokemon/10001/',
          ),
          NamedApiResource(
            name: 'deoxys-defense',
            url: 'https://pokeapi.co/api/v2/pokemon/10002/',
          ),
        ],
        pokemonById: {
          10001: _pokemon(
            id: 10001,
            name: 'deoxys-attack',
            speciesId: 386,
          ),
          10002: _pokemon(
            id: 10002,
            name: 'deoxys-defense',
            speciesId: 386,
          ),
        },
        speciesById: {
          1: _species(id: 1, en: 'Bulbasaur', pt: 'Bulbasaur'),
          386: _species(id: 386, en: 'Deoxys', pt: 'Deoxys'),
        },
      );
      repository = PokemonRepositoryImpl(
        remote: remote,
        local: local,
        gameTextResolver: GameTextResolver(
          machineTranslation: _NoopMachineTranslation(),
          fetchResourceEntries: (_, _) async => const [],
        ),
      );

      await repository.warmPokemonNameIndex();

      expect(remote.listCallCount, 1);
      expect(remote.pokemonCallCount, 2);
      // Default-line species 1 once + form species 386 once (shared cache).
      expect(remote.speciesCallCount, 2);

      final hits = await repository.searchPokemonRefsByName('Deoxys');
      expect(hits.map((r) => r.id), containsAll([10001, 10002]));
    },
  );

  test(
    'piggyback does not upsert name index when index is empty',
    () async {
      remote = _CountingRemote(
        listResults: const [
          NamedApiResource(
            name: 'pikachu',
            url: 'https://pokeapi.co/api/v2/pokemon/25/',
          ),
        ],
        pokemonById: {
          25: _pokemon(
            id: 25,
            name: 'pikachu',
            speciesId: 25,
            isDefault: true,
          ),
        },
        speciesById: {
          25: _species(id: 25, en: 'Pikachu', pt: 'Pikachuzinho'),
        },
      );
      repository = PokemonRepositoryImpl(
        remote: remote,
        local: local,
        gameTextResolver: GameTextResolver(
          machineTranslation: _NoopMachineTranslation(),
          fetchResourceEntries: (_, _) async => const [],
        ),
      );

      // Seed _speciesCache via detail without building the name index.
      await repository.getPokemonDetail(25);
      expect(await repository.isNameIndexReady(), isFalse);

      // Force _loadSummariesForIds network path with species already cached.
      await (db.delete(db.cachedPokemonEntries)
            ..where((t) => t.id.equals(25)))
          .go();
      await repository.getSummariesByIds([25]);

      expect(await repository.isNameIndexReady(), isFalse);
      // Warm must still run full Phase A (not early-return on a partial index).
      await repository.warmPokemonNameIndex();
      expect(remote.listCallCount, 1);
      expect(await repository.isNameIndexReady(), isTrue);
    },
  );

  test(
    'piggyback upserts localized name only when index already ready',
    () async {
      remote = _CountingRemote(
        listResults: const [
          NamedApiResource(
            name: 'pikachu',
            url: 'https://pokeapi.co/api/v2/pokemon/25/',
          ),
        ],
        pokemonById: {
          25: _pokemon(
            id: 25,
            name: 'pikachu',
            speciesId: 25,
            isDefault: true,
          ),
        },
        speciesById: {
          25: _species(id: 25, en: 'Pikachu', pt: 'Pikachuzinho'),
        },
      );
      repository = PokemonRepositoryImpl(
        remote: remote,
        local: local,
        gameTextResolver: GameTextResolver(
          machineTranslation: _NoopMachineTranslation(),
          fetchResourceEntries: (_, _) async => const [],
        ),
      );

      await repository.warmPokemonNameIndex();
      expect(await repository.isNameIndexReady(), isTrue);

      await repository.getPokemonDetail(25);
      await local.replaceNameIndex(const [
        (id: 25, name: 'pikachu', localizedName: 'pikachu'),
      ]);
      await (db.delete(db.cachedPokemonEntries)
            ..where((t) => t.id.equals(25)))
          .go();

      await repository.getSummariesByIds([25]);

      final hits = await repository.searchPokemonRefsByName('Pikachu');
      expect(hits.any((r) => r.id == 25), isTrue);
    },
  );

  test(
    'onLocaleChanged awaits clear then rebuilds A+B for new locale',
    () async {
      final clearStarted = Completer<void>();
      final allowClear = Completer<void>();
      local = _GatedClearLocal(
        db,
        onEmptyClear: () async {
          if (!clearStarted.isCompleted) clearStarted.complete();
          await allowClear.future;
        },
      );
      repository = PokemonRepositoryImpl(
        remote: remote,
        local: local,
        gameTextResolver: GameTextResolver(
          machineTranslation: _NoopMachineTranslation(),
          fetchResourceEntries: (_, _) async => const [],
        ),
      );

      await repository.warmPokemonNameIndex();
      expect(remote.speciesCallCount, 3);
      expect(
        (await repository.searchPokemonRefsByName('Pikachu'))
            .any((r) => r.id == 25),
        isTrue,
      );

      repository.onLocaleChanged(AppLocale.pt);
      await clearStarted.future;
      // If warm raced ahead of clear, it early-returns on the stale ready
      // index and never schedules Phase B for the new locale.
      await Future<void>.delayed(Duration.zero);
      allowClear.complete();
      await repository.warmPokemonNameIndex();

      expect(remote.speciesCallCount, greaterThan(3));
      final ptHits = await repository.searchPokemonRefsByName('Pikachuzinho');
      expect(ptHits.any((r) => r.id == 25), isTrue);
    },
  );
}

/// Delays empty [replaceNameIndex] so locale-clear vs warm races can be tested.
class _GatedClearLocal extends PokemonLocalDataSource {
  _GatedClearLocal(super._db, {required this.onEmptyClear});

  final Future<void> Function() onEmptyClear;

  @override
  Future<void> replaceNameIndex(List<Object> refs) async {
    if (refs.isEmpty) {
      await onEmptyClear();
    }
    return super.replaceNameIndex(refs);
  }
}

PokemonSpeciesResponse _species({
  required int id,
  required String en,
  required String pt,
}) {
  return PokemonSpeciesResponse(
    id: id,
    names: [
      {
        'name': en,
        'language': {'name': 'en'},
      },
      {
        'name': pt,
        'language': {'name': 'pt-br'},
      },
    ],
    genderRate: 4,
    captureRate: 45,
    baseHappiness: 50,
    hatchCounter: 20,
    eggGroups: const ['monster'],
    evolutionChainUrl: null,
  );
}

PokemonResponse _pokemon({
  required int id,
  required String name,
  required int speciesId,
  bool isDefault = false,
}) {
  return PokemonResponse(
    id: id,
    name: name,
    height: 17,
    weight: 608,
    types: const [],
    stats: const [],
    abilities: const [],
    spriteUrl: null,
    listSpriteUrl: null,
    isDefault: isDefault,
    speciesId: speciesId,
  );
}

class _NoopMachineTranslation implements MachineTranslationBackend {
  @override
  Future<String?> translate({
    required String text,
    required String fromLang,
    required String toLang,
  }) async =>
      null;

  @override
  void clearCache() {}
}

class _CountingRemote extends PokemonRemoteDataSource {
  _CountingRemote({
    required this.listResults,
    this.speciesById = const {},
    this.pokemonById = const {},
  }) : super(PokeApiClient(Dio()));

  final List<NamedApiResource> listResults;
  final Map<int, PokemonSpeciesResponse> speciesById;
  final Map<int, PokemonResponse> pokemonById;

  int listCallCount = 0;
  int pokemonCallCount = 0;
  int speciesCallCount = 0;

  @override
  Future<PokemonListResponse> fetchPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    listCallCount++;
    return PokemonListResponse(
      count: listResults.length,
      results: listResults,
    );
  }

  @override
  Future<PokemonResponse> fetchPokemon(int id) async {
    pokemonCallCount++;
    final pokemon = pokemonById[id];
    if (pokemon == null) {
      throw StateError('unexpected fetchPokemon($id)');
    }
    return pokemon;
  }

  @override
  Future<PokemonSpeciesResponse> fetchPokemonSpecies(int id) async {
    speciesCallCount++;
    final species = speciesById[id];
    if (species == null) {
      throw StateError('unexpected fetchPokemonSpecies($id)');
    }
    return species;
  }
}
