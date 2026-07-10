import 'package:pokedex_app/core/locale/api_load_target.dart';
import 'package:pokedex_app/core/locale/game_text_source.dart';
import 'package:pokedex_app/core/locale/machine_translation_backend.dart';
import 'package:pokedex_app/core/locale/poke_api_localized_text.dart';
import 'package:pokedex_app/core/locale/resolved_game_text.dart';

typedef FetchResourceEntries =
    Future<List<dynamic>> Function(ApiLoadTarget resource, String slug);

class GameTextResolver {
  GameTextResolver({
    required this._machineTranslation,
    required this._fetchResourceEntries,
  });

  final MachineTranslationBackend _machineTranslation;
  final FetchResourceEntries _fetchResourceEntries;

  void clearCache() => _machineTranslation.clearCache();

  Future<ResolvedGameText> resolveFromEntries({
    required List<dynamic> entries,
    required GameTextKind kind,
    required String targetLang,
    String? textKey,
    String? slugFallback,
  }) async {
    final key = textKey ?? _textKeyFor(kind);

    final official = PokeApiLocalizedText.pickOfficial(entries, targetLang, key);
    if (official != null) {
      final text = kind == GameTextKind.flavorText
          ? _normalizeFlavor(official)
          : official;
      return ResolvedGameText(text: text, source: GameTextSource.official);
    }

    final english = PokeApiLocalizedText.pickEnglish(entries, key);
    final slugText = _capitalize(slugFallback);
    final sourceText = english ?? slugText;

    if (sourceText == null || sourceText.isEmpty) {
      return const ResolvedGameText(text: '—', source: GameTextSource.slug);
    }

    if (targetLang == 'en') {
      return ResolvedGameText(
        text: kind == GameTextKind.flavorText
            ? _normalizeFlavor(sourceText)
            : sourceText,
        source: english != null
            ? GameTextSource.englishFallback
            : GameTextSource.slug,
      );
    }

    final translated = await _machineTranslation.translate(
      text: kind == GameTextKind.flavorText
          ? _normalizeFlavor(sourceText)
          : sourceText,
      fromLang: 'en',
      toLang: targetLang,
    );

    if (translated != null) {
      return ResolvedGameText(
        text: translated,
        source: GameTextSource.machineTranslated,
      );
    }

    return ResolvedGameText(
      text: kind == GameTextKind.flavorText
          ? _normalizeFlavor(sourceText)
          : sourceText,
      source: GameTextSource.englishFallback,
    );
  }

  Future<ResolvedGameText> resolveResource({
    required ApiLoadTarget resource,
    required String slug,
    required GameTextKind kind,
    required String targetLang,
  }) async {
    final entries = await _fetchResourceEntries(resource, slug);
    return resolveFromEntries(
      entries: entries,
      kind: kind,
      targetLang: targetLang,
      slugFallback: slug,
    );
  }

  static String _textKeyFor(GameTextKind kind) {
    return switch (kind) {
      GameTextKind.name => 'name',
      GameTextKind.flavorText => 'flavor_text',
    };
  }

  static String _normalizeFlavor(String text) {
    return text.replaceAll('\n', ' ').replaceAll('\f', ' ');
  }

  static String? _capitalize(String? value) {
    if (value == null || value.isEmpty) return null;
    return value[0].toUpperCase() + value.substring(1);
  }
}
