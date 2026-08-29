import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_tts_voice_selector.dart';

abstract final class PokemonTtsQualityProfile {
  static const double speechRate = 0.45;
  static const double volume = 1;
  static const double pitch = 1;
}

typedef PokemonTtsEngineFactory = PokemonTtsEngine Function();

abstract interface class PokemonTtsEngine {
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion);
  Future<void> configureIosAudio();
  Future<dynamic> get voices;
  void setCancelHandler(void Function() handler);
  void setCompletionHandler(void Function() handler);
  void setErrorHandler(void Function(dynamic message) handler);
  Future<dynamic> isLanguageAvailable(String language);
  Future<dynamic> setLanguage(String language);
  Future<dynamic> setPitch(double pitch);
  Future<dynamic> setSpeechRate(double rate);
  Future<dynamic> setVoice(Map<String, String> voice);
  Future<dynamic> setVolume(double volume);
  Future<dynamic> speak(String text);
  Future<dynamic> stop();
}

final class _FlutterTtsEngine implements PokemonTtsEngine {
  _FlutterTtsEngine() : _tts = FlutterTts();

  final FlutterTts _tts;

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) =>
      _tts.awaitSpeakCompletion(awaitCompletion);

  @override
  Future<void> configureIosAudio() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;

    try {
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        const [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    } on Object {
      // Audio category support is optional and must not block speech.
    }

    try {
      await _tts.setSharedInstance(true);
    } on Object {
      // Shared audio session support is optional and must not block speech.
    }
  }

  @override
  Future<dynamic> get voices => _tts.getVoices;

  @override
  void setCancelHandler(void Function() handler) =>
      _tts.setCancelHandler(handler);

  @override
  void setCompletionHandler(void Function() handler) =>
      _tts.setCompletionHandler(handler);

  @override
  void setErrorHandler(void Function(dynamic message) handler) =>
      _tts.setErrorHandler(handler);

  @override
  Future<dynamic> isLanguageAvailable(String language) =>
      _tts.isLanguageAvailable(language);

  @override
  Future<dynamic> setLanguage(String language) => _tts.setLanguage(language);

  @override
  Future<dynamic> setPitch(double pitch) => _tts.setPitch(pitch);

  @override
  Future<dynamic> setSpeechRate(double rate) => _tts.setSpeechRate(rate);

  @override
  Future<dynamic> setVoice(Map<String, String> voice) => _tts.setVoice(voice);

  @override
  Future<dynamic> setVolume(double volume) => _tts.setVolume(volume);

  @override
  Future<dynamic> speak(String text) => _tts.speak(text);

  @override
  Future<dynamic> stop() => _tts.stop();
}

enum PokemonDescriptionTtsStatus { idle, speaking, error }

class const PokemonDescriptionTtsState({
  final PokemonDescriptionTtsStatus status = PokemonDescriptionTtsStatus.idle,
});

class PokemonDescriptionTtsNotifier
    extends Notifier<PokemonDescriptionTtsState> {
  PokemonDescriptionTtsNotifier({
    PokemonTtsEngineFactory? engineFactory,
  }) : _engineFactory = engineFactory ?? _FlutterTtsEngine.new;

  final PokemonTtsEngineFactory _engineFactory;
  PokemonTtsEngine? _tts;
  var _initialized = false;

  @override
  PokemonDescriptionTtsState build() {
    ref.onDispose(() {
      final tts = _tts;
      _tts = null;
      _initialized = false;
      if (tts != null) {
        unawaited(tts.stop());
      }
    });
    return const PokemonDescriptionTtsState();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    final tts = _tts ??= _engineFactory();
    await _tryApply(() => tts.awaitSpeakCompletion(true));
    await _tryApply(
      () => tts.setSpeechRate(PokemonTtsQualityProfile.speechRate),
    );
    await _tryApply(() => tts.setVolume(PokemonTtsQualityProfile.volume));
    await _tryApply(() => tts.setPitch(PokemonTtsQualityProfile.pitch));
    await _tryConfigureIosAudio(tts);
    tts
      ..setCompletionHandler(_onFinished)
      ..setCancelHandler(_onFinished)
      ..setErrorHandler((_) => _onFinished());

    _initialized = true;
  }

  Future<void> _tryApply(Future<dynamic> Function() operation) async {
    try {
      await operation();
    } on Object {
      // Optional engine configuration must not block speech.
    }
  }

  Future<void> _tryConfigureIosAudio(PokemonTtsEngine tts) async {
    try {
      await tts.configureIosAudio();
    } on Object {
      // Audio category support is optional and must not block speech.
    }
  }

  void _onFinished() {
    if (!ref.mounted) return;
    state = const PokemonDescriptionTtsState();
  }

  Future<String> _resolveLanguage(AppLocale locale) async {
    final tts = _tts!;
    final candidates = <String>[
      locale.tag,
      locale.languageCode,
      AppLocale.en.tag,
    ];

    for (final candidate in candidates) {
      final available = await tts.isLanguageAvailable(candidate);
      if (available == true) {
        return candidate;
      }
    }

    return locale.tag;
  }

  Future<void> speak({
    required String text,
    required AppLocale locale,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _ensureInitialized();
    final tts = _tts!;
    await tts.stop();

    final language = await _resolveLanguage(locale);
    await tts.setLanguage(language);
    await _trySelectVoice(tts, language);

    if (!ref.mounted) return;
    state = const PokemonDescriptionTtsState(
      status: PokemonDescriptionTtsStatus.speaking,
    );

    try {
      final result = await tts.speak(trimmed);
      if (!ref.mounted) return;
      if (result != 1) {
        state = const PokemonDescriptionTtsState(
          status: PokemonDescriptionTtsStatus.error,
        );
      }
    } on Object {
      if (!ref.mounted) return;
      state = const PokemonDescriptionTtsState(
        status: PokemonDescriptionTtsStatus.error,
      );
    }
  }

  Future<void> _trySelectVoice(PokemonTtsEngine tts, String language) async {
    dynamic availableVoices;
    try {
      availableVoices = await tts.voices;
    } on Object {
      return;
    }

    if (availableVoices is! List<dynamic>) return;

    try {
      final voice = PokemonTtsVoiceSelector.select(
        voices: availableVoices,
        locale: language,
      );
      if (voice != null) {
        await tts.setVoice(voice);
      }
    } on Object {
      // Voice selection is optional; setLanguage remains the fallback.
    }
  }

  Future<void> stop() async {
    await _tts?.stop();
    if (!ref.mounted) return;
    state = const PokemonDescriptionTtsState();
  }

  Future<void> toggle({
    required String text,
    required AppLocale locale,
  }) async {
    if (state.status == PokemonDescriptionTtsStatus.speaking) {
      await stop();
      return;
    }
    await speak(text: text, locale: locale);
  }
}

final NotifierProvider<
  PokemonDescriptionTtsNotifier,
  PokemonDescriptionTtsState
>
pokemonDescriptionTtsProvider =
    NotifierProvider<PokemonDescriptionTtsNotifier, PokemonDescriptionTtsState>(
      PokemonDescriptionTtsNotifier.new,
    );
