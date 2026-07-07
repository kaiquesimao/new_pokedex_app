import 'package:pokedex_app/l10n/generated/app_localizations.dart';

/// Firebase Auth provider id for email/password accounts.
const passwordAuthProviderId = 'password';

/// Whether the account supports in-app credential edits.
///
/// [providerIds] are Firebase Auth `providerId` values from the signed-in user.
/// When empty (mock/local auth), treat as a password account.
bool accountCanEditCredentials(Iterable<String> providerIds) {
  final ids = providerIds.toList();
  if (ids.isEmpty) return true;
  return ids.contains(passwordAuthProviderId);
}

String socialAccountCredentialsMessage(AppLocalizations l10n) {
  return l10n.profileSocialAccountCredentials;
}
