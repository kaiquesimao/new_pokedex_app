import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// App ARB delegate plus Material, Cupertino, and Widgets delegates.
///
/// Use this instead of [AppLocalizations.localizationsDelegates]: gen-l10n
/// still wires `package:flutter_localizations`, while Material widgets now
/// resolve localizations from `package:material_ui`.
List<LocalizationsDelegate<dynamic>> get appLocalizationDelegates => [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
