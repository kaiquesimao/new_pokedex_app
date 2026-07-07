import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:riverpod/misc.dart';

Future<void> pumpLocalizedApp(
  WidgetTester tester, {
  required Widget child,
  AppLocale locale = AppLocale.pt,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profileSettingsProvider.overrideWithBuild(
          (ref, notifier) => ProfileSettings(appLanguage: locale.tag),
        ),
        ...overrides,
      ],
      child: MaterialApp(
        locale: locale.materialLocale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
