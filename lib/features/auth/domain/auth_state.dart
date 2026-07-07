class AuthState {
  const AuthState({
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.emailVerified = true,
    this.uid,
    this.email,
    this.displayName,
    this.canEditCredentials = true,
  });

  final bool isInitialized;
  final bool isAuthenticated;
  final bool emailVerified;
  final String? uid;
  final String? email;
  final String? displayName;

  /// Password, email, and display name edits — only for email/password accounts.
  final bool canEditCredentials;

  bool get needsEmailVerification => isAuthenticated && !emailVerified;

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
