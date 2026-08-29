import 'package:pokedex_app/core/locale/app_locale.dart';

abstract final class PokemonTtsVoiceSelector {
  static Map<String, String>? select({
    required List<dynamic> voices,
    required AppLocale locale,
  }) {
    final requestedLocale = _normalizeLocale(locale.tag);
    final requestedLanguage = _languageCode(requestedLocale);
    final candidates = <_VoiceCandidate>[];

    for (final voice in voices) {
      if (voice is! Map) continue;

      final voiceLocale = _stringValue(voice['locale']);
      final name = _stringValue(voice['name']);
      final identifier = _stringValue(voice['identifier']);
      if (voiceLocale == null || (name == null && identifier == null)) {
        continue;
      }

      final normalizedLocale = _normalizeLocale(voiceLocale);
      if (_languageCode(normalizedLocale) != requestedLanguage) continue;

      candidates.add(
        _VoiceCandidate(
          locale: voiceLocale,
          name: name,
          identifier: identifier,
          isExactLocale: normalizedLocale == requestedLocale,
          quality: _numericValue(voice['quality']),
          networkRequired: _booleanValue(voice['network_required']),
        ),
      );
    }

    if (candidates.isEmpty) return null;

    candidates.sort(_compareCandidates);
    return candidates.first.voice;
  }

  static int _compareCandidates(_VoiceCandidate left, _VoiceCandidate right) {
    final exactLocale = _compareBooleans(
      left.isExactLocale,
      right.isExactLocale,
    );
    if (exactLocale != 0) return exactLocale;

    final quality = right.quality.compareTo(left.quality);
    if (quality != 0) return quality;

    if (left.networkRequired != right.networkRequired) {
      return left.networkRequired ? 1 : -1;
    }

    return left.identity.compareTo(right.identity);
  }

  static int _compareBooleans(bool left, bool right) {
    if (left == right) return 0;
    return left ? -1 : 1;
  }

  static String _normalizeLocale(String locale) =>
      locale.trim().replaceAll('_', '-').toLowerCase();

  static String _languageCode(String locale) => locale.split('-').first;

  static String? _stringValue(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double _numericValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static bool _booleanValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.trim().toLowerCase() == 'true';
    return false;
  }
}

final class const _VoiceCandidate({
  required final String locale,
  required final String? name,
  required final String? identifier,
  required final bool isExactLocale,
  required final double quality,
  required final bool networkRequired,
}) {
  String get identity => name ?? identifier!;

  Map<String, String> get voice {
    final voiceName = name;
    if (voiceName != null) {
      return {'name': voiceName, 'locale': locale};
    }
    return {'identifier': identifier!};
  }
}
