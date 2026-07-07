// Mirrors Firebase Authentication password policy (Console → Authentication).
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

abstract final class PasswordPolicy {
  static const int minLength = 6;
  static const int maxLength = 4096;

  static String requirementsHintOf(AppLocalizations l10n) =>
      l10n.authWeakPassword;

  static String? validateWithL10n(AppLocalizations l10n, String password) {
    if (password.length < minLength) {
      return l10n.authPasswordTooShort(minLength);
    }
    if (password.length > maxLength) {
      return l10n.authPasswordTooLong(maxLength);
    }
    return null;
  }
}
