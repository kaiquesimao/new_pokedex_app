class AuthState {
  const AuthState({
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.uid,
    this.email,
    this.displayName,
  });

  final bool isInitialized;
  final bool isAuthenticated;
  final String? uid;
  final String? email;
  final String? displayName;

  AuthState copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    String? uid,
    String? email,
    String? displayName,
    bool clearUser = false,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      uid: clearUser ? null : (uid ?? this.uid),
      email: clearUser ? null : (email ?? this.email),
      displayName: clearUser ? null : (displayName ?? this.displayName),
    );
  }
}
