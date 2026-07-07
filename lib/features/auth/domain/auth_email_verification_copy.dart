/// Shared user-facing copy for e-mail verification flows.
abstract final class AuthEmailVerificationCopy {
  static const spamReminder =
      'Se não encontrar, verifique também a pasta de spam ou lixo eletrônico.';

  static const unverifiedFirebase =
      'E-mail ainda não verificado. Abra o link enviado e tente novamente. '
      'Se não encontrar, verifique também a pasta de spam ou lixo eletrônico.';

  static String withSpamReminder(String message) => '$message $spamReminder';
}
