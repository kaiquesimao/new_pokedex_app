import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// App ARB delegate plus Material, Cupertino, and Widgets delegates.
///
/// Use this instead of [AppLocalizations.localizationsDelegates]: gen-l10n
/// still wires `package:flutter_localizations`, while Material widgets now
/// resolve localizations from `package:material_ui`.
///
/// `flutter_markdown_plus` still builds its selection toolbar with
/// `package:flutter/material`, which looks up a different
/// [MaterialLocalizations] type than `material_ui`. Both delegates have to be
/// registered or that toolbar throws on copy/select.
List<LocalizationsDelegate<dynamic>> get appLocalizationDelegates => [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
  flutter_localizations.GlobalMaterialLocalizations.delegate,
  flutter_localizations.GlobalCupertinoLocalizations.delegate,
];
