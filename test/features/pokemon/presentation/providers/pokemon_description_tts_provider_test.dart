import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_description_tts_provider.dart';

class _RecordingDescriptionTts extends PokemonDescriptionTtsNotifier {
  final List<({String text, AppLocale locale})> speakCalls = [];
  final List<void Function()> stopCalls = [];

  @override
  PokemonDescriptionTtsState build() => const PokemonDescriptionTtsState();

  @override
  Future<void> speak({
    required String text,
    required AppLocale locale,
  }) async {
    speakCalls.add((text: text, locale: locale));
    state = const PokemonDescriptionTtsState(
      status: PokemonDescriptionTtsStatus.speaking,
    );
  }

  @override
  Future<void> stop() async {
    stopCalls.add(() {});
    state = const PokemonDescriptionTtsState();
  }
}

void main() {
  test('uses the natural high-quality speech profile', () {
    expect(PokemonTtsQualityProfile.speechRate, 0.45);
    expect(PokemonTtsQualityProfile.volume, 1.0);
    expect(PokemonTtsQualityProfile.pitch, 1.0);
  });

  test('toggle starts speaking when idle', () async {
    final recorder = _RecordingDescriptionTts();
    final container = ProviderContainer(
      overrides: [
        pokemonDescriptionTtsProvider.overrideWith(() => recorder),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(pokemonDescriptionTtsProvider.notifier)
        .toggle(
          text: 'A strange seed was planted on its back at birth.',
          locale: AppLocale.en,
        );

    expect(recorder.speakCalls, hasLength(1));
    expect(recorder.speakCalls.single.locale, AppLocale.en);
    expect(
      container.read(pokemonDescriptionTtsProvider).status,
      PokemonDescriptionTtsStatus.speaking,
    );
  });

  test('toggle stops when already speaking', () async {
    final recorder = _RecordingDescriptionTts();
    final container = ProviderContainer(
      overrides: [
        pokemonDescriptionTtsProvider.overrideWith(() => recorder),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(pokemonDescriptionTtsProvider.notifier);
    await notifier.speak(text: 'Bulbasaur description.', locale: AppLocale.pt);
    await notifier.toggle(
      text: 'Bulbasaur description.',
      locale: AppLocale.pt,
    );

    expect(recorder.stopCalls, hasLength(1));
    expect(
      container.read(pokemonDescriptionTtsProvider).status,
      PokemonDescriptionTtsStatus.idle,
    );
  });

  test('stop resets speaking state', () async {
    final recorder = _RecordingDescriptionTts();
    final container = ProviderContainer(
      overrides: [
        pokemonDescriptionTtsProvider.overrideWith(() => recorder),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(pokemonDescriptionTtsProvider.notifier);
    await notifier.speak(text: 'Charmander description.', locale: AppLocale.en);
    await notifier.stop();

    expect(recorder.stopCalls, hasLength(1));
    expect(
      container.read(pokemonDescriptionTtsProvider).status,
      PokemonDescriptionTtsStatus.idle,
    );
  });
}
