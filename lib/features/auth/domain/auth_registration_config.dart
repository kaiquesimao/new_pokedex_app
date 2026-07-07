/// Registration policy toggles for email/password sign-up.
abstract final class AuthRegistrationConfig {
  /// When false, a verification e-mail is still sent (best-effort), but the user
  /// enters the app immediately without confirming the link.
  static const bool requireEmailVerification = false;
}
