import 'dart:ui';

import 'package:pokedex_app/core/locale/app_locale.dart';

abstract final class LocaleResolver {
  static AppLocale fromSystemLocale(Locale locale) =>
      AppLocale.fromSystemLocale(locale);

  static AppLocale fromPlatform() =>
      fromSystemLocale(PlatformDispatcher.instance.locale);
}
