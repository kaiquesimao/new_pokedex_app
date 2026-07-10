import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/core/locale/game_text_resolver.dart';
import 'package:pokedex_app/core/locale/game_text_source.dart';
import 'package:pokedex_app/core/locale/machine_translation_backend.dart';
import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/models/pokemon_models.dart';
import 'package:pokedex_app/features/pokemon/data/repositories/pokemon_repository_impl.dart';

class _PikachuGeneraRemote extends PokemonRemoteDataSource {
  _PikachuGeneraRemote(this._speciesJson) : super(_StubClient());

  final Map<String, dynamic> _speciesJson;

  @override
  Future<PokemonResponse> fetchPokemon(int id) async {
    return PokemonResponse.fromJson({
      'id': 25,
      'name': 'pikachu',
      'height': 4,
      'weight': 60,
      'sprites': <String, dynamic>{},
      'types': <dynamic>[],
      'stats': <dynamic>[],
      'abilities': <dynamic>[],
    });
  }

  @override
  Future<PokemonSpeciesResponse> fetchPokemonSpecies(int id) async {
    return PokemonSpeciesResponse.fromJson(_speciesJson);
  }
}

class _StubClient implements PokeApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test('getPokemonDetail sets category from genus', () async {
    final speciesJson = jsonDecode(
      await File('test/fixtures/species_pikachu_genera.json').readAsString(),
    ) as Map<String, dynamic>;

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repository = PokemonRepositoryImpl(
      remote: _PikachuGeneraRemote(speciesJson),
      local: PokemonLocalDataSource(db),
      gameTextResolver: GameTextResolver(
        machineTranslation: InMemoryMachineTranslationBackend(),
        fetchResourceEntries: (_, _) async => [],
      ),
    );

    final detail = await repository.getPokemonDetail(25);

    expect(detail.category, 'Mouse Pokémon');
  });

  test('getPokemonDetail leaves category null when genera empty', () async {
    final speciesJson = <String, dynamic>{
      'id': 25,
      'genera': <dynamic>[],
      'names': <dynamic>[],
      'flavor_text_entries': <dynamic>[],
      'gender_rate': 4,
      'capture_rate': 190,
      'base_happiness': 70,
      'hatch_counter': 10,
      'egg_groups': <dynamic>[],
      'evolution_chain': <String, dynamic>{'url': ''},
      'varieties': <dynamic>[],
    };

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repository = PokemonRepositoryImpl(
      remote: _PikachuGeneraRemote(speciesJson),
      local: PokemonLocalDataSource(db),
      gameTextResolver: GameTextResolver(
        machineTranslation: InMemoryMachineTranslationBackend(),
        fetchResourceEntries: (_, _) async => [],
      ),
    );

    final detail = await repository.getPokemonDetail(25);

    expect(detail.category, isNull);
  });

  test('resolveFromEntries machine-translates genus for pt-br', () async {
    final resolver = GameTextResolver(
      machineTranslation: InMemoryMachineTranslationBackend(
        translateFn: (_, _, _) async => 'Pokémon Rato',
      ),
      fetchResourceEntries: (_, _) async => [],
    );

    final result = await resolver.resolveFromEntries(
      entries: [
        {
          'genus': 'Mouse Pokémon',
          'language': {'name': 'en'},
        },
      ],
      kind: GameTextKind.name,
      targetLang: 'pt-br',
      textKey: 'genus',
    );

    expect(result.text, 'Pokémon Rato');
    expect(result.source, GameTextSource.machineTranslated);
  });
}
