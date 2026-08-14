import 'package:pokedex_app/features/auth/domain/auth_registration_config.dart';

class const AuthState({
  final bool isInitialized = false,
  final bool isAuthenticated = false,
  final bool emailVerified = true,
  final String? uid,
  final String? email,
  final String? displayName,

  /// Password, email, and display name edits — only for email/password accounts.
  final bool canEditCredentials = true,
}) {
  bool get needsEmailVerification =>
      AuthRegistrationConfig.requireEmailVerification &&
      isAuthenticated &&
      !emailVerified;

  AuthState copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    bool? emailVerified,
    String? uid,
    String? email,
    String? displayName,
    bool? canEditCredentials,
    bool clearUser = false,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      emailVerified: emailVerified ?? this.emailVerified,
      uid: clearUser ? null : (uid ?? this.uid),
      email: clearUser ? null : (email ?? this.email),
      displayName: clearUser ? null : (displayName ?? this.displayName),
      canEditCredentials:
          clearUser || (canEditCredentials ?? this.canEditCredentials),
    );
  }
}
