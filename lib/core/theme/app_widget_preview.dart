import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/theme/app_theme.dart';
import 'package:pokedex_app/l10n/app_localization_delegates.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// Light/dark [Theme] for Widget Preview, following the preview brightness.
PreviewThemeData appPreviewTheme() => const AppPreviewThemeData();

/// English UI copy plus Material delegates for isolated widget previews.
PreviewLocalizationsData appPreviewLocalizations() {
  return PreviewLocalizationsData(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: appLocalizationDelegates,
  );
}

/// Applies [AppTheme] inside the Widget Preview environment.
final class AppPreviewThemeData extends PreviewThemeData {
  /// Creates a preview theme that tracks [MediaQuery] brightness.
  const AppPreviewThemeData();

  @override
  Widget apply(BuildContext context, Widget child) {
    final brightness = MediaQuery.maybePlatformBrightnessOf(context);
    return Theme(
      data: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
      child: child,
    );
  }
}
