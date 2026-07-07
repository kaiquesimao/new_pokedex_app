import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/core/network/poke_api_client.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import 'package:pokedex_app/features/pokemon/data/repositories/pokemon_repository_impl.dart';

class _EggGroupRemote extends PokemonRemoteDataSource {
  _EggGroupRemote(this._eggGroupJson) : super(_StubClient());

  final Map<String, dynamic> _eggGroupJson;

  @override
  Future<Map<String, dynamic>> fetchEggGroup(String name) async {
    return _eggGroupJson;
  }
}

class _StubClient implements PokeApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test('getEggGroupDisplayName returns localized name', () async {
    final fixture = jsonDecode(
      await File('test/fixtures/egg_group_monster.json').readAsString(),
    ) as Map<String, dynamic>;

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final repository = PokemonRepositoryImpl(
      remote: _EggGroupRemote(fixture),
      local: PokemonLocalDataSource(db),
    );

    final display = await repository.getEggGroupDisplayName(
      'monster',
      'pt-br',
    );

    expect(display, 'Monstro');
    expect(display, isNot('Monster'));
  });
}
