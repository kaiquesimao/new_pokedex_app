import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_cry_player_provider.dart';

class _RecordingCryPlayer extends PokemonCryPlayerNotifier {
  final List<({String? cryUrl, String? legacyCryUrl})> calls = [];

  @override
  PokemonCryPlayerState build() => const PokemonCryPlayerState();

  @override
  Future<void> playCry({
    String? cryUrl,
    String? legacyCryUrl,
    int? pokemonId,
  }) async {
    calls.add((cryUrl: cryUrl, legacyCryUrl: legacyCryUrl));
  }
}

void main() {
  test('playCry forwards URLs to notifier', () async {
    final recorder = _RecordingCryPlayer();
    final container = ProviderContainer(
      overrides: [
        pokemonCryPlayerProvider.overrideWith(() => recorder),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(pokemonCryPlayerProvider.notifier)
        .playCry(
          cryUrl: 'https://example.com/latest.ogg',
          legacyCryUrl: 'https://example.com/legacy.ogg',
        );

    expect(recorder.calls, hasLength(1));
    expect(recorder.calls.single.cryUrl, 'https://example.com/latest.ogg');
    expect(
      recorder.calls.single.legacyCryUrl,
      'https://example.com/legacy.ogg',
    );
  });
}
