import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/core/locale/game_text_resolver.dart';
import 'package:pokedex_app/core/locale/machine_translation_backend.dart';
import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/models/evolution_models.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/data/repositories/pokemon_repository_impl.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/evolution_chain.dart';

class _CharizardMegaRemote extends PokemonRemoteDataSource {
  _CharizardMegaRemote() : super(_RecordingClient());

  @override
  Future<PokemonResponse> fetchPokemon(int id) async {
    if (id == 10034) {
      return PokemonResponse.fromJson({
        'id': 10034,
        'name': 'charizard-mega-x',
        'is_default': false,
        'species': {
          'name': 'charizard',
          'url': 'https://pokeapi.co/api/v2/pokemon-species/6/',
        },
        'forms': [
          {
            'name': 'charizard-mega-x',
            'url': 'https://pokeapi.co/api/v2/pokemon-form/10034/',
          },
        ],
        'height': 17,
        'weight': 1105,
        'sprites': <String, dynamic>{},
        'types': <dynamic>[
          {
            'slot': 1,
            'type': {'name': 'fire'},
          },
          {
            'slot': 2,
            'type': {'name': 'dragon'},
          },
        ],
        'stats': <dynamic>[],
        'abilities': <dynamic>[],
      });
    }

    return PokemonResponse.fromJson({
      'id': id,
      'name': switch (id) {
        4 => 'charmander',
        5 => 'charmeleon',
        6 => 'charizard',
        _ => 'pokemon-$id',
      },
      'is_default': true,
      'height': 10,
      'weight': 100,
      'sprites': <String, dynamic>{},
      'types': <dynamic>[
        {
          'slot': 1,
          'type': {'name': 'fire'},
        },
      ],
      'stats': <dynamic>[],
      'abilities': <dynamic>[],
    });
  }

  @override
  Future<PokemonFormResponse> fetchPokemonForm(int id) async {
    return const PokemonFormResponse(isMega: true);
  }

  @override
  Future<PokemonSpeciesResponse> fetchPokemonSpecies(int id) async {
    return const PokemonSpeciesResponse(
      id: 6,
      names: [],
      genderRate: 4,
      captureRate: 45,
      baseHappiness: 70,
      hatchCounter: 20,
      eggGroups: ['monster', 'dragon'],
      evolutionChainUrl: 'https://pokeapi.co/api/v2/evolution-chain/2/',
    );
  }

  @override
  Future<EvolutionChainResponse> fetchEvolutionChain(int id) async {
    return EvolutionChainResponse.fromJson({
      'id': 2,
      'chain': {
        'species': {
          'name': 'charmander',
          'url': 'https://pokeapi.co/api/v2/pokemon-species/4/',
        },
        'evolves_to': [
          {
            'species': {
              'name': 'charmeleon',
              'url': 'https://pokeapi.co/api/v2/pokemon-species/5/',
            },
            'evolution_details': [
              {
                'min_level': 16,
                'trigger': {'name': 'level-up'},
              },
            ],
            'evolves_to': [
              {
                'species': {
                  'name': 'charizard',
                  'url': 'https://pokeapi.co/api/v2/pokemon-species/6/',
                },
                'evolution_details': [
                  {
                    'min_level': 36,
                    'trigger': {'name': 'level-up'},
                  },
                ],
                'evolves_to': <dynamic>[],
              },
            ],
          },
        ],
      },
    });
  }
}

class _RecordingClient implements PokeApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

EvolutionChainNode? _findNodeBySpeciesId(
  EvolutionChainNode node,
  int speciesId,
) {
  if (node.speciesId == speciesId) return node;
  for (final child in node.evolvesTo) {
    final found = _findNodeBySpeciesId(child, speciesId);
    if (found != null) return found;
  }
  return null;
}

void main() {
  test(
    'getEvolutionChain shows selected form at matching species stage',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final local = PokemonLocalDataSource(db);
      final remote = _CharizardMegaRemote();
      final repository = PokemonRepositoryImpl(
        remote: remote,
        local: local,
        gameTextResolver: GameTextResolver(
          machineTranslation: InMemoryMachineTranslationBackend(),
          fetchResourceEntries: (_, _) async => [],
        ),
      );

      final chain = await repository.getEvolutionChain(10034);

      expect(chain.currentPokemonId, 10034);
      expect(chain.currentSpeciesId, 6);

      final charizardNode = _findNodeBySpeciesId(chain.root, 6);
      expect(charizardNode, isNotNull);
      expect(charizardNode!.pokemonId, 10034);
      expect(charizardNode.speciesName, 'charizard-mega-x');

      final charmanderNode = _findNodeBySpeciesId(chain.root, 4);
      expect(charmanderNode?.pokemonId, 4);
      expect(charmanderNode?.speciesName, 'charmander');
    },
  );

  test(
    'resolvePokemonIdForRegionalSpecies maps species to regional variety',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final local = PokemonLocalDataSource(db);
      final remote = _GrimerAlolaRemote();
      final repository = PokemonRepositoryImpl(
        remote: remote,
        local: local,
        gameTextResolver: GameTextResolver(
          machineTranslation: InMemoryMachineTranslationBackend(),
          fetchResourceEntries: (_, _) async => [],
        ),
      );

      expect(
        await repository.resolvePokemonIdForRegionalSpecies(88, 'alola'),
        10112,
      );
      expect(
        await repository.resolvePokemonIdForRegionalSpecies(89, 'alola'),
        10113,
      );
      expect(
        await repository.resolvePokemonIdForRegionalSpecies(88, 'hisui'),
        88,
      );
    },
  );

  test('getEvolutionChain resolves regional forms across the chain', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final local = PokemonLocalDataSource(db);
    final remote = _GrimerAlolaRemote();
    final repository = PokemonRepositoryImpl(
      remote: remote,
      local: local,
      gameTextResolver: GameTextResolver(
        machineTranslation: InMemoryMachineTranslationBackend(),
        fetchResourceEntries: (_, _) async => [],
      ),
    );

    final chain = await repository.getEvolutionChain(10112);

    expect(chain.currentPokemonId, 10112);
    expect(chain.currentSpeciesId, 88);

    final grimerNode = _findNodeBySpeciesId(chain.root, 88);
    expect(grimerNode?.pokemonId, 10112);
    expect(grimerNode?.speciesName, 'grimer-alola');

    final mukNode = _findNodeBySpeciesId(chain.root, 89);
    expect(mukNode?.pokemonId, 10113);
    expect(mukNode?.speciesName, 'muk-alola');
    expect(remote.speciesFetchCount, 2);
  });
}

class _GrimerAlolaRemote extends PokemonRemoteDataSource {
  _GrimerAlolaRemote() : super(_RecordingClient());

  int speciesFetchCount = 0;

  @override
  Future<PokemonResponse> fetchPokemon(int id) async {
    return PokemonResponse.fromJson({
      'id': id,
      'name': switch (id) {
        88 => 'grimer',
        89 => 'muk',
        10112 => 'grimer-alola',
        10113 => 'muk-alola',
        _ => 'pokemon-$id',
      },
      'is_default': id == 88 || id == 89,
      'species': {
        'name': switch (id) {
          10112 || 88 => 'grimer',
          10113 || 89 => 'muk',
          _ => 'pokemon',
        },
        'url': switch (id) {
          10112 || 88 => 'https://pokeapi.co/api/v2/pokemon-species/88/',
          10113 || 89 => 'https://pokeapi.co/api/v2/pokemon-species/89/',
          _ => 'https://pokeapi.co/api/v2/pokemon-species/1/',
        },
      },
      'height': 10,
      'weight': 100,
      'sprites': <String, dynamic>{},
      'types': <dynamic>[
        {
          'slot': 1,
          'type': {'name': 'poison'},
        },
      ],
      'stats': <dynamic>[],
      'abilities': <dynamic>[],
    });
  }

  @override
  Future<PokemonSpeciesResponse> fetchPokemonSpecies(int id) async {
    speciesFetchCount++;
    if (id == 88) {
      return const PokemonSpeciesResponse(
        id: 88,
        names: [],
        genderRate: 4,
        captureRate: 190,
        baseHappiness: 70,
        hatchCounter: 20,
        eggGroups: ['amorphous'],
        evolutionChainUrl: 'https://pokeapi.co/api/v2/evolution-chain/37/',
        varieties: [
          PokemonSpeciesVariety(
            isDefault: true,
            pokemonId: 88,
            pokemonName: 'grimer',
          ),
          PokemonSpeciesVariety(
            isDefault: false,
            pokemonId: 10112,
            pokemonName: 'grimer-alola',
          ),
        ],
      );
    }

    return const PokemonSpeciesResponse(
      id: 89,
      names: [],
      genderRate: 4,
      captureRate: 75,
      baseHappiness: 70,
      hatchCounter: 20,
      eggGroups: ['amorphous'],
      evolutionChainUrl: 'https://pokeapi.co/api/v2/evolution-chain/37/',
      varieties: [
        PokemonSpeciesVariety(
          isDefault: true,
          pokemonId: 89,
          pokemonName: 'muk',
        ),
        PokemonSpeciesVariety(
          isDefault: false,
          pokemonId: 10113,
          pokemonName: 'muk-alola',
        ),
      ],
    );
  }

  @override
  Future<EvolutionChainResponse> fetchEvolutionChain(int id) async {
    return EvolutionChainResponse.fromJson({
      'id': 37,
      'chain': {
        'species': {
          'name': 'grimer',
          'url': 'https://pokeapi.co/api/v2/pokemon-species/88/',
        },
        'evolves_to': [
          {
            'species': {
              'name': 'muk',
              'url': 'https://pokeapi.co/api/v2/pokemon-species/89/',
            },
            'evolution_details': [
              {
                'min_level': 38,
                'trigger': {'name': 'level-up'},
              },
            ],
            'evolves_to': <dynamic>[],
          },
        ],
      },
    });
  }
}
