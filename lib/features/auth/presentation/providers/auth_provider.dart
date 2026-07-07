import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pokedex_app/core/constants/firebase_auth_config.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/auth_account_policy.dart';
import 'package:pokedex_app/features/auth/domain/auth_registration_config.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/domain/display_name_policy.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

const _authKey = 'mock_auth_session';
const _emailKey = 'mock_auth_email';
const _nameKey = 'mock_auth_name';
const _passwordKey = 'mock_auth_password';
const _pendingEmailKey = 'mock_auth_pending_email';
const _mockOtpDelay = Duration(milliseconds: 600);

AuthState readStoredAuthState(SharedPreferences prefs) {
  return AuthState(
    isInitialized: true,
    isAuthenticated: prefs.getBool(_authKey) ?? false,
    email: prefs.getString(_emailKey),
    displayName: prefs.getString(_nameKey),
  );
}

AuthState _authStateFromFirebaseUser(User? user) {
  if (user == null) {
    return const AuthState(isInitialized: true);
  }
  return AuthState(
    isInitialized: true,
    isAuthenticated: true,
    emailVerified: user.emailVerified,
    uid: user.uid,
    email: user.email,
    displayName: user.displayName ?? user.email?.split('@').first,
    canEditCredentials: accountCanEditCredentials(
      user.providerData.map((provider) => provider.providerId),
    ),
  );
}

class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<User?>? _authSubscription;

  FirebaseAuth? get _firebaseAuth {
    final bootstrap = ref.read(firebaseBootstrapProvider);
    return bootstrap.isAvailable ? FirebaseAuth.instance : null;
  }

  ConnectivityService get _connectivity =>
      ref.read(connectivityServiceProvider);

  bool get _googleSignInEnabled =>
      ref.read(firebaseBootstrapProvider).isAvailable;

  bool get usesFirebase => _firebaseAuth != null;

  bool get _allowLocalAuth => !kReleaseMode;

  void _requireLocalAuth() {
    if (!_allowLocalAuth) {
      throw AuthException(
        'Serviço indisponível. Tente novamente mais tarde.',
      );
    }
  }

  @override
  AuthState build() {
    ref.onDispose(() => _authSubscription?.cancel());
    final bootstrap = ref.watch(firebaseBootstrapProvider);
    if (bootstrap.isAvailable) {
      return const AuthState();
    }
    if (!_allowLocalAuth) {
      return const AuthState(isInitialized: true);
    }
    return readStoredAuthState(ref.watch(sharedPreferencesProvider));
  }

  void _requireOnline() {
    if (!_connectivity.isOnline) {
      throw AuthException('Sem conexão com a internet.');
    }
  }

  void _requirePasswordAccount() {
    if (!state.canEditCredentials) {
      throw AuthException(socialAccountCredentialsMessage);
    }
  }

  Future<void> _sendRegistrationVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
    } on Object catch (e) {
      if (AuthRegistrationConfig.requireEmailVerification) {
        throw AuthException(
          firebaseAuthErrorMessage(
            e,
            context: FirebaseAuthErrorContext.emailSignUp,
          ),
        );
      }
    }
  }

  bool _shouldPreserveEmailVerified(User? user, AuthState next) {
    if (user == null || AuthRegistrationConfig.requireEmailVerification) {
      return false;
    }
    return state.emailVerified &&
        !next.emailVerified &&
        state.email == next.email;
  }

  /// Reloads the Firebase user and syncs [AuthState] (e.g. after e-mail change).
  Future<bool> refreshAuthenticatedUser() async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null) return false;

    _requireOnline();
    final user = firebaseAuth.currentUser;
    if (user == null) return false;

    try {
      await user.reload();
      final refreshed = firebaseAuth.currentUser;
      if (refreshed == null) return false;
      state = _authStateFromFirebaseUser(refreshed);
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthException(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> initialize() async {
    if (state.isInitialized) return;

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      _authSubscription = firebaseAuth.authStateChanges().listen((user) {
        final next = _authStateFromFirebaseUser(user);
        final preserveVerified = _shouldPreserveEmailVerified(user, next);
        state = preserveVerified ? next.copyWith(emailVerified: true) : next;
      });
      state = _authStateFromFirebaseUser(firebaseAuth.currentUser);
      return;
    }

    _requireLocalAuth();

    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool(_authKey) ?? false;

    state = AuthState(
      isInitialized: true,
      isAuthenticated: isAuthenticated,
      email: prefs.getString(_emailKey),
      displayName: prefs.getString(_nameKey),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Preencha e-mail e senha');
    }

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      _requireOnline();
      try {
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        state = _authStateFromFirebaseUser(firebaseAuth.currentUser);
      } catch (e) {
        throw AuthException(
          firebaseAuthErrorMessage(
            e,
            context: FirebaseAuthErrorContext.emailSignIn,
          ),
        );
      }
      return;
    }

    _requireLocalAuth();

    final prefs = await SharedPreferences.getInstance();
    final name = email.split('@').first;

    await prefs.setBool(_authKey, true);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_passwordKey, password);

    state = AuthState(
      isInitialized: true,
      isAuthenticated: true,
      email: email,
      displayName: name,
    );
  }

  void _requireValidPassword(String password) {
    final error = PasswordPolicy.validate(password);
    if (error != null) throw AuthException(error);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw AuthException('Preencha todos os campos');
    }
    _requireValidPassword(password);

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      _requireOnline();
      final user = firebaseAuth.currentUser;
      if (user != null && user.email == email) {
        final wasVerified = state.emailVerified;
        await user.updateDisplayName(name);
        await user.reload();
        final refreshed = firebaseAuth.currentUser;
        final next = _authStateFromFirebaseUser(refreshed);
        state = wasVerified && !next.emailVerified
            ? next.copyWith(emailVerified: true)
            : next;
        return;
      }

      try {
        final credential = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await credential.user?.updateDisplayName(name);
        final createdUser = credential.user;
        if (createdUser != null) {
          await _sendRegistrationVerificationEmail(createdUser);
        }
        state = _authStateFromFirebaseUser(firebaseAuth.currentUser);
        if (!AuthRegistrationConfig.requireEmailVerification) {
          state = state.copyWith(emailVerified: true);
        }
      } catch (e) {
        throw AuthException(
          firebaseAuthErrorMessage(
            e,
            context: FirebaseAuthErrorContext.emailSignUp,
          ),
        );
      }
      return;
    }

    _requireLocalAuth();

    await signIn(email: email, password: password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    state = state.copyWith(displayName: name);
  }

  Future<void> createPendingAccount({
    required String email,
    required String password,
  }) async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null) return;

    _requireValidPassword(password);
    _requireOnline();

    final trimmedEmail = email.trim();
    final currentUser = firebaseAuth.currentUser;
    if (currentUser != null && currentUser.email == trimmedEmail) {
      return;
    }

    if (currentUser != null) {
      await signOut();
    }

    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      state = _authStateFromFirebaseUser(firebaseAuth.currentUser);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        firebaseAuthErrorMessage(
          e,
          context: FirebaseAuthErrorContext.emailSignUp,
        ),
      );
    }
  }

  Future<void> completePendingRegistration({required String name}) async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null) return;

    _requireOnline();
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw AuthException('Sessão inválida');
    }

    try {
      await user.updateDisplayName(name);
      await _sendRegistrationVerificationEmail(user);
      await user.reload();
      state = _authStateFromFirebaseUser(firebaseAuth.currentUser);
      if (!AuthRegistrationConfig.requireEmailVerification) {
        state = state.copyWith(emailVerified: true);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        firebaseAuthErrorMessage(
          e,
          context: FirebaseAuthErrorContext.emailSignUp,
        ),
      );
    }
  }

  Future<void> signOut() async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      if (_googleSignInEnabled) {
        await FirebaseAuthConfig.ensureGoogleSignInInitialized();
        await GoogleSignIn.instance.signOut();
      }
      await firebaseAuth.signOut();
      state = const AuthState(isInitialized: true);
      return;
    }

    _requireLocalAuth();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_passwordKey);
    state = const AuthState(isInitialized: true);
  }

  Future<bool> verifyCurrentPassword(String password) async {
    _requirePasswordAccount();

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      _requireOnline();
      final user = firebaseAuth.currentUser;
      final email = user?.email;
      if (user == null || email == null || email.isEmpty) return false;

      try {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        return true;
      } on FirebaseAuthException {
        return false;
      }
    }

    _requireLocalAuth();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_passwordKey);
    if (stored == null || stored.isEmpty) return password.isNotEmpty;
    return stored == password;
  }

  Future<void> sendOtp({required String email}) async {
    if (email.isEmpty || !email.contains('@')) {
      throw AuthException('Informe um e-mail válido');
    }

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      _requireOnline();
      final user = firebaseAuth.currentUser;
      if (user != null && user.email == email) {
        await user.sendEmailVerification();
        return;
      }
      throw AuthException('Crie a conta antes de verificar o e-mail');
    }

    _requireLocalAuth();
    await Future<void>.delayed(_mockOtpDelay);
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    if (email.isEmpty || !email.contains('@')) {
      throw AuthException('Informe um e-mail válido');
    }

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      _requireOnline();
      try {
        await firebaseAuth.sendPasswordResetEmail(email: email);
      } catch (e) {
        throw AuthException(firebaseAuthErrorMessage(e));
      }
      return;
    }

    _requireLocalAuth();
    await Future<void>.delayed(_mockOtpDelay);
  }

  /// Keeps [AuthState.emailVerified] in sync after registration verification.
  void acknowledgeEmailVerification() {
    if (state.isAuthenticated && !state.emailVerified) {
      state = state.copyWith(emailVerified: true);
    }
  }

  Future<bool> verifyOtp({required String email, required String code}) async {
    if (email.isEmpty) return false;

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      _requireOnline();
      final user = firebaseAuth.currentUser;
      if (user == null || user.email != email) return false;
      await user.reload();
      final refreshed = firebaseAuth.currentUser;
      if (refreshed != null) {
        state = _authStateFromFirebaseUser(refreshed);
      }
      return refreshed?.emailVerified ?? false;
    }

    _requireLocalAuth();
    await Future<void>.delayed(_mockOtpDelay);
    return code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code);
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _requireValidPassword(newPassword);

    if (_firebaseAuth != null) {
      throw AuthException(
        'Use o link enviado por e-mail para redefinir a senha',
      );
    }

    _requireLocalAuth();
    await Future<void>.delayed(_mockOtpDelay);

    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_emailKey);
    if (storedEmail != null && storedEmail == email) {
      await prefs.setString(_passwordKey, newPassword);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!state.isAuthenticated) {
      throw AuthException('Faça login para alterar a senha');
    }
    _requirePasswordAccount();

    _requireValidPassword(newPassword);

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      _requireOnline();
      final user = firebaseAuth.currentUser;
      final email = user?.email;
      if (user == null || email == null) {
        throw AuthException('Sessão inválida');
      }

      try {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      } catch (e) {
        throw AuthException(firebaseAuthErrorMessage(e));
      }
      return;
    }

    _requireLocalAuth();

    final valid = await verifyCurrentPassword(currentPassword);
    if (!valid) {
      throw AuthException('Senha atual incorreta');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, newPassword);
  }

  Future<void> updateDisplayName(String name) async {
    if (!state.isAuthenticated) {
      throw AuthException('Faça login para continuar');
    }
    _requirePasswordAccount();

    final trimmed = name.trim();
    final validationError = DisplayNamePolicy.validate(trimmed);
    if (validationError != null) {
      throw AuthException(validationError);
    }

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      _requireOnline();
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('Sessão inválida');
      }

      try {
        await user.updateDisplayName(trimmed);
        await user.reload();
        state = _authStateFromFirebaseUser(firebaseAuth.currentUser);
      } catch (e) {
        throw AuthException(firebaseAuthErrorMessage(e));
      }
      return;
    }

    _requireLocalAuth();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, trimmed);
    state = state.copyWith(displayName: trimmed);
  }

  Future<void> requestEmailChange({
    required String currentPassword,
    required String newEmail,
  }) async {
    if (!state.isAuthenticated) {
      throw AuthException('Faça login para continuar');
    }
    _requirePasswordAccount();

    final trimmedEmail = newEmail.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw AuthException('Informe um e-mail válido');
    }
    if (trimmedEmail == state.email) {
      throw AuthException('O novo e-mail deve ser diferente do atual');
    }

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      _requireOnline();
      final user = firebaseAuth.currentUser;
      final currentEmail = user?.email;
      if (user == null || currentEmail == null || currentEmail.isEmpty) {
        throw AuthException('Sessão inválida');
      }

      try {
        final credential = EmailAuthProvider.credential(
          email: currentEmail,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.verifyBeforeUpdateEmail(trimmedEmail);
      } catch (e) {
        throw AuthException(
          firebaseAuthErrorMessage(
            e,
            context: FirebaseAuthErrorContext.emailSignUp,
          ),
        );
      }
      return;
    }

    _requireLocalAuth();

    final valid = await verifyCurrentPassword(currentPassword);
    if (!valid) {
      throw AuthException('Senha atual incorreta');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingEmailKey, trimmedEmail);
    await Future<void>.delayed(_mockOtpDelay);
  }

  Future<bool> completeEmailChangeVerification({
    required String expectedEmail,
    String otpCode = '',
  }) async {
    final trimmedExpected = expectedEmail.trim();

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      await refreshAuthenticatedUser();
      final email = state.email;
      return email != null &&
          email.toLowerCase() == trimmedExpected.toLowerCase();
    }

    _requireLocalAuth();

    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getString(_pendingEmailKey);
    if (pending == null ||
        pending.toLowerCase() != trimmedExpected.toLowerCase()) {
      return false;
    }

    final verified = await verifyOtp(email: pending, code: otpCode);
    if (!verified) return false;

    await prefs.setString(_emailKey, pending);
    await prefs.remove(_pendingEmailKey);
    state = state.copyWith(email: pending);
    return true;
  }

  Future<void> signInWithGoogle() async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null || !_googleSignInEnabled) {
      throw AuthException('Login com Google indisponível');
    }

    _requireOnline();
    try {
      await FirebaseAuthConfig.ensureGoogleSignInInitialized();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw AuthException('Use o botão do Google para entrar');
      }

      final googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email'],
      );
      await signInWithGoogleAccount(googleUser);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      throw AuthException(
        firebaseAuthErrorMessage(e, context: FirebaseAuthErrorContext.oauth),
      );
    } catch (e) {
      throw AuthException(
        firebaseAuthErrorMessage(e, context: FirebaseAuthErrorContext.oauth),
      );
    }
  }

  Future<void> signInWithGoogleAccount(GoogleSignInAccount googleUser) async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null || !_googleSignInEnabled) {
      throw AuthException('Login com Google indisponível');
    }

    _requireOnline();
    try {
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await firebaseAuth.signInWithCredential(credential);
      state = _authStateFromFirebaseUser(firebaseAuth.currentUser);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      throw AuthException(
        firebaseAuthErrorMessage(e, context: FirebaseAuthErrorContext.oauth),
      );
    } catch (e) {
      throw AuthException(
        firebaseAuthErrorMessage(e, context: FirebaseAuthErrorContext.oauth),
      );
    }
  }

  Future<void> signInWithApple() async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null) {
      throw AuthException('Login com Apple indisponível');
    }

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw AuthException('Login com Apple disponível apenas no iOS');
    }

    _requireOnline();
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await firebaseAuth.signInWithCredential(oauthCredential);
      state = _authStateFromFirebaseUser(firebaseAuth.currentUser);
    } catch (e) {
      throw AuthException(
        firebaseAuthErrorMessage(e, context: FirebaseAuthErrorContext.oauth),
      );
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
