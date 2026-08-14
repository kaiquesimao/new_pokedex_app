import 'package:material_ui/material_ui.dart';

enum AppLocale({
  required final String languageCode,
  required final String countryCode,
  required final String pokeApiCode,
  required final String tag,
}) {
  pt(
    languageCode: 'pt',
    countryCode: 'BR',
    pokeApiCode: 'pt-br',
    tag: 'pt-BR',
  ),
  en(
    languageCode: 'en',
    countryCode: 'US',
    pokeApiCode: 'en',
    tag: 'en-US',
  );

  Locale get materialLocale => Locale(languageCode, countryCode);

  static const supportedMaterialLocales = [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
  ];

  static AppLocale fromTag(String tag) {
    return switch (tag) {
      'pt-BR' => AppLocale.pt,
      'en-US' => AppLocale.en,
      _ => AppLocale.en,
    };
  }

  static AppLocale fromSystemLocale(Locale locale) {
    if (locale.languageCode == 'pt') return AppLocale.pt;
    return AppLocale.en;
  }

  /// Picks the first supported locale from [preferredLocales], else [en].
  static AppLocale fromPreferredLocales(List<Locale> preferredLocales) {
    for (final locale in preferredLocales) {
      if (locale.languageCode == 'pt') return AppLocale.pt;
      if (locale.languageCode == 'en') return AppLocale.en;
    }
    return AppLocale.en;
  }
}
