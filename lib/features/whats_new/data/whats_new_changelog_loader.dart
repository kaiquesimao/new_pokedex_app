import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';

/// Play listing notes bundled from `store/google_play/*/changelogs`.
String whatsNewChangelogAssetPath({
  required String localeTag,
  required int versionCode,
}) {
  return 'store/google_play/$localeTag/changelogs/$versionCode.txt';
}

class WhatsNewChangelogLoader {
  new({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Loads the changelog for [versionCode], preferring [locale] and then the
  /// other bundled store locale. Returns null when every candidate is missing
  /// or blank.
  Future<String?> loadBody({
    required AppLocale locale,
    required int versionCode,
  }) async {
    final tags = switch (locale) {
      AppLocale.pt => const ['pt-BR', 'en-US'],
      AppLocale.en => const ['en-US', 'pt-BR'],
    };
    for (final tag in tags) {
      final body = await _read(
        whatsNewChangelogAssetPath(localeTag: tag, versionCode: versionCode),
      );
      if (body != null) return body;
    }
    return null;
  }

  Future<String?> _read(String path) async {
    try {
      final text = (await _bundle.loadString(path)).trim();
      if (text.isEmpty) return null;
      return text;
      // AssetBundle.loadString reports a missing file as FlutterError.
      // ignore: avoid_catching_errors
    } on FlutterError {
      return null;
    }
  }
}
