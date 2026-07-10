import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/locale_resolver.dart';

void main() {
  group('LocaleResolver.fromSystemLocale', () {
    test('resolves pt-BR to AppLocale.pt', () {
      expect(
        LocaleResolver.fromSystemLocale(const Locale('pt', 'BR')),
        AppLocale.pt,
      );
    });

    test('resolves fr-FR to AppLocale.en fallback', () {
      expect(
        LocaleResolver.fromSystemLocale(const Locale('fr', 'FR')),
        AppLocale.en,
      );
    });
  });

  group('AppLocale.pokeApiCode', () {
    test('pt uses pt-br for PokeAPI', () {
      expect(AppLocale.pt.pokeApiCode, 'pt-br');
    });

    test('en uses en for PokeAPI', () {
      expect(AppLocale.en.pokeApiCode, 'en');
    });
  });

  group('AppLocale.fromPreferredLocales', () {
    test('resolves pt-BR from preferred list', () {
      expect(
        AppLocale.fromPreferredLocales(const [Locale('pt', 'BR')]),
        AppLocale.pt,
      );
    });

    test('resolves en from preferred list', () {
      expect(
        AppLocale.fromPreferredLocales(const [Locale('en', 'US')]),
        AppLocale.en,
      );
    });

    test('falls back to en when no supported locale matches', () {
      expect(
        AppLocale.fromPreferredLocales(const [Locale('fr', 'FR')]),
        AppLocale.en,
      );
    });
  });

  group('AppLocale.fromTag', () {
    test('round-trips pt-BR', () {
      expect(AppLocale.fromTag('pt-BR'), AppLocale.pt);
      expect(AppLocale.pt.tag, 'pt-BR');
    });

    test('round-trips en-US', () {
      expect(AppLocale.fromTag('en-US'), AppLocale.en);
      expect(AppLocale.en.tag, 'en-US');
    });

    test('unknown tag falls back to en', () {
      expect(AppLocale.fromTag('fr-FR'), AppLocale.en);
    });
  });
}
