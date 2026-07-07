/// Shared user-facing copy for e-mail verification flows.
library;

import 'package:pokedex_app/l10n/generated/app_localizations.dart';

abstract final class AuthEmailVerificationCopy {
  static String spamReminder(AppLocalizations l10n) => l10n.authSpamReminder;

  static String unverifiedFirebase(AppLocalizations l10n) =>
      l10n.authUnverifiedFirebase;

  static String withSpamReminder(AppLocalizations l10n, String message) {
    return '$message ${spamReminder(l10n)}';
  }
}
