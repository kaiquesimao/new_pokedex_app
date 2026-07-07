import 'package:flutter/material.dart';

enum AppLocale {
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

  const AppLocale({
    required this.languageCode,
    required this.countryCode,
    required this.pokeApiCode,
    required this.tag,
  });

  final String languageCode;
  final String countryCode;
  final String pokeApiCode;
  final String tag;

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
}
