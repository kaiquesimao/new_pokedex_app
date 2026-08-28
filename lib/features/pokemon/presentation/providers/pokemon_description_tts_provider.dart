import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';

enum PokemonDescriptionTtsStatus { idle, speaking, error }

class const PokemonDescriptionTtsState({
  final PokemonDescriptionTtsStatus status = PokemonDescriptionTtsStatus.idle,
});

class PokemonDescriptionTtsNotifier
    extends Notifier<PokemonDescriptionTtsState> {
  FlutterTts? _tts;
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

    final tts = _tts ??= FlutterTts();
    await tts.awaitSpeakCompletion(true);
    tts
      ..setCompletionHandler(_onFinished)
      ..setCancelHandler(_onFinished)
      ..setErrorHandler((_) => _onFinished());

    _initialized = true;
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

final NotifierProvider<PokemonDescriptionTtsNotifier, PokemonDescriptionTtsState>
pokemonDescriptionTtsProvider =
    NotifierProvider<PokemonDescriptionTtsNotifier, PokemonDescriptionTtsState>(
      PokemonDescriptionTtsNotifier.new,
    );
