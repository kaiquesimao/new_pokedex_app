import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/game_text_resolver.dart';
import 'package:pokedex_app/core/locale/game_text_resolver_provider.dart';
import 'package:pokedex_app/core/locale/game_text_source.dart';
import 'package:pokedex_app/core/locale/machine_translation_backend.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/localized_flavor_text_provider.dart';

void main() {
  test('skips MT when official pt-br flavor exists', () async {
    final container = ProviderContainer(
      overrides: [
        gameTextResolverProvider.overrideWithValue(
          GameTextResolver(
            machineTranslation: InMemoryMachineTranslationBackend(
              translateFn: (_, _, _) async => throw Exception('should not run'),
            ),
            fetchResourceEntries: (_, _) async => [],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      localizedFlavorTextProvider((
        flavorEntries: [
          {
            'flavor_text': 'Um rato.',
            'language': {'name': 'pt-br'},
          },
        ],
        targetLang: 'pt-br',
      )).future,
    );

    expect(result?.text, 'Um rato.');
    expect(result?.source, GameTextSource.official);
  });

  test('machine-translates en-only flavor entries', () async {
    final container = ProviderContainer(
      overrides: [
        gameTextResolverProvider.overrideWithValue(
          GameTextResolver(
            machineTranslation: InMemoryMachineTranslationBackend(
              translateFn: (text, from, to) async => 'TRAD:$text',
            ),
            fetchResourceEntries: (_, _) async => [],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      localizedFlavorTextProvider((
        flavorEntries: [
          {
            'flavor_text': 'A mouse.',
            'language': {'name': 'en'},
          },
        ],
        targetLang: 'pt-br',
      )).future,
    );

    expect(result?.text, 'TRAD:A mouse.');
    expect(result?.source, GameTextSource.machineTranslated);
  });
}
