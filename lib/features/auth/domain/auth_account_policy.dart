/// Firebase Auth provider id for email/password accounts.
const passwordAuthProviderId = 'password';

/// Message shown when a social account tries to edit password, email, or name.
const socialAccountCredentialsMessage =
    'Contas Google ou Apple não permitem alterar senha, e-mail ou nome por aqui.';

/// Whether the account supports in-app credential edits.
///
/// [providerIds] are Firebase Auth `providerId` values from the signed-in user.
/// When empty (mock/local auth), treat as a password account.
bool accountCanEditCredentials(Iterable<String> providerIds) {
  final ids = providerIds.toList();
  if (ids.isEmpty) return true;
  return ids.contains(passwordAuthProviderId);
}
