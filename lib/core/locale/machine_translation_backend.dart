import 'package:translator/translator.dart';

abstract interface class MachineTranslationBackend {
  Future<String?> translate({
    required String text,
    required String fromLang,
    required String toLang,
  });

  void clearCache();
}

typedef TranslateFn = Future<String> Function(
  String text,
  String fromLang,
  String toLang,
);

class InMemoryMachineTranslationBackend implements MachineTranslationBackend {
  InMemoryMachineTranslationBackend({TranslateFn? translateFn})
    : _translateFn = translateFn ?? _defaultTranslate;

  final TranslateFn _translateFn;
  final Map<String, String> _cache = {};

  static String _translatorLang(String pokeApiCode) {
    return switch (pokeApiCode) {
      'pt-br' => 'pt',
      _ => pokeApiCode,
    };
  }

  static Future<String> _defaultTranslate(
    String text,
    String fromLang,
    String toLang,
  ) async {
    final translation = await GoogleTranslator().translate(
      text,
      from: _translatorLang(fromLang),
      to: _translatorLang(toLang),
    );
    return translation.text;
  }

  @override
  Future<String?> translate({
    required String text,
    required String fromLang,
    required String toLang,
  }) async {
    if (text.isEmpty) return text;
    if (fromLang == toLang) return text;

    final cacheKey = '$fromLang:$toLang:${text.hashCode}';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    try {
      final translated = await _translateFn(text, fromLang, toLang);
      _cache[cacheKey] = translated;
      return translated;
    } on Object {
      return null;
    }
  }

  @override
  void clearCache() => _cache.clear();
}
