/// Mirrors Firebase Authentication password policy (Console → Authentication).
abstract final class PasswordPolicy {
  static const int minLength = 6;
  static const int maxLength = 4096;

  static const String requirementsHint =
      'Use entre $minLength e $maxLength caracteres.';

  static String? validate(String password) {
    if (password.length < minLength) {
      return 'A senha deve ter pelo menos $minLength caracteres.';
    }
    if (password.length > maxLength) {
      return 'A senha deve ter no máximo $maxLength caracteres.';
    }
    return null;
  }
}
