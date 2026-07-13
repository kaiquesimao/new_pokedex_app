import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/database/app_database.dart';
import 'package:pokedex_app/features/pokemon/data/datasources/pokemon_local_datasource.dart';
import 'package:pokedex_app/features/pokemon/domain/entities/pokemon_ref.dart';

void main() {
  late AppDatabase db;
  late PokemonLocalDataSource local;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    local = PokemonLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('replaceNameIndex stores and searches pokemon names', () async {
    await local.replaceNameIndex(const [
      PokemonRef(id: 25, name: 'pikachu'),
      PokemonRef(id: 1, name: 'bulbasaur'),
      PokemonRef(id: 26, name: 'raichu'),
    ]);

    expect(await local.isNameIndexReady(), isTrue);

    final results = await local.searchRefsByName('pika');
    expect(results.map((ref) => ref.id), [25]);
  });

  test('searchRefsByName is case-insensitive', () async {
    await local.replaceNameIndex(const [PokemonRef(id: 4, name: 'charmander')]);

    final results = await local.searchRefsByName('CHAR');
    expect(results, hasLength(1));
    expect(results.first.name, 'charmander');
  });

  test('getIndexedRefs returns all stored entries', () async {
    await local.replaceNameIndex(const [
      PokemonRef(id: 7, name: 'squirtle'),
      PokemonRef(id: 8, name: 'wartortle'),
    ]);

    final refs = await local.getIndexedRefs();
    expect(refs, hasLength(2));
    expect(refs.map((ref) => ref.id), containsAll([7, 8]));
  });

  test('upsertNameIndex updates localizedName without wiping other rows',
      () async {
    await local.replaceNameIndex(const [
      (id: 25, name: 'pikachu', localizedName: 'pikachu'),
      (id: 1, name: 'bulbasaur', localizedName: 'bulbasaur'),
    ]);

    await local.upsertNameIndex(const [
      (id: 25, name: 'pikachu', localizedName: 'Pikachu'),
    ]);

    expect(await local.isNameIndexReady(), isTrue);
    final byPika = await local.searchRefsByName('Pikachu');
    expect(byPika.map((r) => r.id), [25]);

    final all = await local.getIndexedRefs();
    expect(all.map((r) => r.id), containsAll([1, 25]));
  });

  test('searchRefsByName matches localizedName', () async {
    await local.replaceNameIndex(const [
      (id: 25, name: 'pikachu', localizedName: 'Pikachu'),
    ]);
    final results = await local.searchRefsByName('pika');
    expect(results.map((r) => r.id), [25]);
  });
}
