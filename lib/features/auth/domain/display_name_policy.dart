import 'package:pokedex_app/l10n/generated/app_localizations.dart';

class DisplayNamePolicy {
  DisplayNamePolicy._();

  static const int maxLength = 64;

  static String? validateWithL10n(AppLocalizations l10n, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return l10n.authEnterYourName;
    }
    if (trimmed.length > maxLength) {
      return l10n.authDisplayNameTooLong(maxLength);
    }
    return null;
  }
}
