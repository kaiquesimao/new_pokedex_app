import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/data/repositories/pokemon_repository_impl.dart';

class _ZygardeMegaRemote extends PokemonRemoteDataSource {
  _ZygardeMegaRemote() : super(_RecordingClient());

  int? lastSpeciesIdRequested;

  @override
  Future<PokemonResponse> fetchPokemon(int id) async {
    return PokemonResponse.fromJson({
      'id': 10301,
      'name': 'zygarde-mega',
      'is_default': false,
      'species': {
        'name': 'zygarde',
        'url': 'https://pokeapi.co/api/v2/pokemon-species/718/',
      },
      'forms': [
        {
          'name': 'zygarde-mega',
          'url': 'https://pokeapi.co/api/v2/pokemon-form/10526/',
        },
      ],
      'height': 77,
      'weight': 6100,
      'sprites': <String, dynamic>{},
      'types': <dynamic>[],
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
    lastSpeciesIdRequested = id;
    return PokemonSpeciesResponse.withFlavorText(
      id: 718,
      flavorText: 'Zygarde species',
      captureRate: 3,
      hatchCounter: 120,
      eggGroups: ['dragon'],
      evolutionChainUrl: 'https://pokeapi.co/api/v2/evolution-chain/371/',
    );
  }

  @override
  Future<Map<String, dynamic>> fetchEggGroup(String name) async {
    return {
      'names': [
        {'language': {'name': 'en'}, 'name': 'Dragon'},
      ],
    };
  }
}

class _RecordingClient implements PokeApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test('getPokemonDetail resolves species id for mega forms', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final local = PokemonLocalDataSource(db);
    final remote = _ZygardeMegaRemote();
    final repository = PokemonRepositoryImpl(remote: remote, local: local);

    // Stale cache without species_id (pre-fix detail json).
    await local.savePokemonResponse(
      PokemonResponse.fromJson({
        'id': 10301,
        'name': 'zygarde-mega',
        'height': 77,
        'weight': 6100,
        'is_default': false,
        'sprites': <String, dynamic>{},
        'types': <dynamic>[],
        'stats': <dynamic>[],
        'abilities': <dynamic>[],
      }),
    );

    final detail = await repository.getPokemonDetail(10301);

    expect(remote.lastSpeciesIdRequested, 718);
    expect(detail.id, 10301);
    expect(detail.flavorText, 'Zygarde species');
  });

  test(
    'getPokemonDetail ignores stale species_id equal to pokemon id',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final local = PokemonLocalDataSource(db);
      final remote = _ZygardeMegaRemote();
      final repository = PokemonRepositoryImpl(remote: remote, local: local);

      await local.savePokemonResponse(
        PokemonResponse.fromJson({
          'id': 10301,
          'name': 'zygarde-mega',
          'height': 77,
          'weight': 6100,
          'is_default': false,
          'species_id': 10301,
          'sprites': <String, dynamic>{},
          'types': <dynamic>[],
          'stats': <dynamic>[],
          'abilities': <dynamic>[],
        }),
      );

      await repository.getPokemonDetail(10301);

      expect(remote.lastSpeciesIdRequested, 718);
    },
  );
}
