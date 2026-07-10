import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/api_load_target.dart';
import 'package:pokedex_app/core/locale/game_text_resolver.dart';
import 'package:pokedex_app/core/locale/game_text_source.dart';
import 'package:pokedex_app/core/locale/machine_translation_backend.dart';

void main() {
  late InMemoryMachineTranslationBackend mt;
  late GameTextResolver resolver;

  setUp(() {
    mt = InMemoryMachineTranslationBackend(
      translateFn: (text, from, to) async => 'TRAD:$text',
    );
    resolver = GameTextResolver(
      machineTranslation: mt,
      fetchResourceEntries: (resource, slug) async {
        if (resource == ApiLoadTarget.ability && slug == 'static') {
          return [
            {
              'name': 'Static',
              'language': {'name': 'en'},
            },
          ];
        }
        return [];
      },
    );
  });

  test('resolveFromEntries returns official when pt-br exists', () async {
    final result = await resolver.resolveFromEntries(
      entries: [
        {
          'genus': 'Pokémon Rato',
          'language': {'name': 'pt-br'},
        },
      ],
      kind: GameTextKind.name,
      targetLang: 'pt-br',
      textKey: 'genus',
    );

    expect(result.text, 'Pokémon Rato');
    expect(result.source, GameTextSource.official);
  });

  test('resolveFromEntries machine-translates when pt-br missing', () async {
    final result = await resolver.resolveFromEntries(
      entries: [
        {
          'flavor_text': 'A mouse.',
          'language': {'name': 'en'},
        },
      ],
      kind: GameTextKind.flavorText,
      targetLang: 'pt-br',
      textKey: 'flavor_text',
    );

    expect(result.text, 'TRAD:A mouse.');
    expect(result.source, GameTextSource.machineTranslated);
  });

  test('resolveFromEntries falls back to en when MT fails', () async {
    mt = InMemoryMachineTranslationBackend(
      translateFn: (_, _, _) async => throw Exception('fail'),
    );
    resolver = GameTextResolver(
      machineTranslation: mt,
      fetchResourceEntries: (_, _) async => [],
    );

    final result = await resolver.resolveFromEntries(
      entries: [
        {
          'name': 'Static',
          'language': {'name': 'en'},
        },
      ],
      kind: GameTextKind.name,
      targetLang: 'pt-br',
      textKey: 'name',
    );

    expect(result.text, 'Static');
    expect(result.source, GameTextSource.englishFallback);
  });

  test('resolveResource fetches ability names', () async {
    final result = await resolver.resolveResource(
      resource: ApiLoadTarget.ability,
      slug: 'static',
      kind: GameTextKind.name,
      targetLang: 'pt-br',
    );

    expect(result.text, 'TRAD:Static');
    expect(result.source, GameTextSource.machineTranslated);
  });
}
