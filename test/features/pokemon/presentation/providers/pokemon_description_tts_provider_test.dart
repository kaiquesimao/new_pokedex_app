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

class _FakeTtsEngine implements PokemonTtsEngine {
  dynamic voicePayload = <dynamic>[];
  final Map<String, bool> languageAvailability = {};
  final List<double> speechRates = [];
  final List<double> volumes = [];
  final List<double> pitches = [];
  final List<String> languages = [];
  final List<Map<String, String>> selectedVoices = [];
  final List<String> spokenTexts = [];
  bool throwWhenReadingVoices = false;
  bool throwWhenSelectingVoice = false;

  @override
  Future<void> awaitSpeakCompletion({required bool awaitCompletion}) async {}

  @override
  Future<void> configureIosAudio() async {}

  @override
  Future<dynamic> get voices async {
    if (throwWhenReadingVoices) {
      throw StateError('voice discovery failed');
    }
    return voicePayload;
  }

  @override
  void setCancelHandler(void Function() handler) {}

  @override
  void setCompletionHandler(void Function() handler) {}

  @override
  void setErrorHandler(void Function(dynamic message) handler) {}

  @override
  Future<dynamic> setLanguage(String language) async {
    languages.add(language);
    return 1;
  }

  @override
  Future<dynamic> setPitch(double pitch) async {
    pitches.add(pitch);
    return 1;
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    speechRates.add(rate);
    return 1;
  }

  @override
  Future<dynamic> setVoice(Map<String, String> voice) async {
    if (throwWhenSelectingVoice) {
      throw StateError('voice selection failed');
    }
    selectedVoices.add(voice);
    return 1;
  }

  @override
  Future<dynamic> setVolume(double volume) async {
    volumes.add(volume);
    return 1;
  }

  @override
  Future<dynamic> speak(String text) async {
    spokenTexts.add(text);
    return 1;
  }

  @override
  Future<dynamic> stop() async => 1;

  @override
  Future<bool> isLanguageAvailable(String language) async =>
      languageAvailability[language] ?? false;
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

  test(
    'applies the quality profile once and selects a compatible voice',
    () async {
      final engine = _FakeTtsEngine()
        ..languageAvailability['en-US'] = true
        ..voicePayload = [
          {
            'name': 'English Enhanced',
            'locale': 'en-US',
            'quality': 'enhanced',
            'identifier': 'com.apple.voice.enhanced.en-US.Test',
          },
        ];
      final container = ProviderContainer(
        overrides: [
          pokemonDescriptionTtsProvider.overrideWith(
            () => PokemonDescriptionTtsNotifier(engineFactory: () => engine),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(pokemonDescriptionTtsProvider.notifier);
      await notifier.speak(text: 'A description.', locale: AppLocale.en);
      await notifier.speak(text: 'Another description.', locale: AppLocale.en);

      expect(engine.speechRates, [PokemonTtsQualityProfile.speechRate]);
      expect(engine.volumes, [PokemonTtsQualityProfile.volume]);
      expect(engine.pitches, [PokemonTtsQualityProfile.pitch]);
      expect(engine.languages, ['en-US', 'en-US']);
      expect(engine.selectedVoices, hasLength(2));
      expect(
        engine.selectedVoices.first['identifier'],
        'com.apple.voice.enhanced.en-US.Test',
      );
    },
  );

  test('selects a voice using the resolved fallback language', () async {
    final engine = _FakeTtsEngine()
      ..languageAvailability['en-US'] = true
      ..voicePayload = [
        {'name': 'English', 'locale': 'en-US', 'quality': 'high'},
      ];
    final container = ProviderContainer(
      overrides: [
        pokemonDescriptionTtsProvider.overrideWith(
          () => PokemonDescriptionTtsNotifier(engineFactory: () => engine),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(pokemonDescriptionTtsProvider.notifier)
        .speak(text: 'Descrição.', locale: AppLocale.pt);

    expect(engine.languages, ['en-US']);
    expect(engine.selectedVoices, [
      {'name': 'English', 'locale': 'en-US'},
    ]);
  });

  test('continues speaking when voice discovery fails', () async {
    final engine = _FakeTtsEngine()
      ..languageAvailability['en-US'] = true
      ..throwWhenReadingVoices = true;
    final container = ProviderContainer(
      overrides: [
        pokemonDescriptionTtsProvider.overrideWith(
          () => PokemonDescriptionTtsNotifier(engineFactory: () => engine),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(pokemonDescriptionTtsProvider.notifier)
        .speak(text: 'A description.', locale: AppLocale.en);

    expect(engine.spokenTexts, ['A description.']);
  });

  test('continues speaking when voice selection fails', () async {
    final engine = _FakeTtsEngine()
      ..languageAvailability['en-US'] = true
      ..throwWhenSelectingVoice = true
      ..voicePayload = [
        {'name': 'English', 'locale': 'en-US', 'quality': 'high'},
      ];
    final container = ProviderContainer(
      overrides: [
        pokemonDescriptionTtsProvider.overrideWith(
          () => PokemonDescriptionTtsNotifier(engineFactory: () => engine),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(pokemonDescriptionTtsProvider.notifier)
        .speak(text: 'A description.', locale: AppLocale.en);

    expect(engine.spokenTexts, ['A description.']);
  });
}
