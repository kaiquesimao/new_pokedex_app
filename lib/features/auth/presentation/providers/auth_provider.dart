import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pokedex_app/core/constants/firebase_auth_config.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

const _authKey = 'mock_auth_session';
const _emailKey = 'mock_auth_email';
const _nameKey = 'mock_auth_name';
const _passwordKey = 'mock_auth_password';
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
    uid: user.uid,
    email: user.email,
    displayName: user.displayName ?? user.email?.split('@').first,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    AuthState? initial,
    this._firebaseAuth,
    this._googleSignIn,
    ConnectivityService? connectivity,
  }) : _connectivity = connectivity,
       super(initial ?? const AuthState());

  final FirebaseAuth? _firebaseAuth;
  final GoogleSignIn? _googleSignIn;
  final ConnectivityService? _connectivity;
  StreamSubscription<User?>? _authSubscription;

  bool get usesFirebase => _firebaseAuth != null;

  void _requireOnline() {
    final connectivity = _connectivity;
    if (connectivity != null && !connectivity.isOnline) {
      throw Exception('Sem conexão com a internet.');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> initialize() async {
    if (state.isInitialized) return;

    if (_firebaseAuth != null) {
      _authSubscription = _firebaseAuth.authStateChanges().listen((user) {
        state = _authStateFromFirebaseUser(user);
      });
      state = _authStateFromFirebaseUser(_firebaseAuth.currentUser);
      return;
    }

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
      throw Exception('Preencha e-mail e senha');
    }

    if (_firebaseAuth != null) {
      _requireOnline();
      try {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        state = _authStateFromFirebaseUser(_firebaseAuth.currentUser);
      } catch (e) {
        throw Exception(firebaseAuthErrorMessage(e));
      }
      return;
    }

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

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('Preencha todos os campos');
    }

    if (_firebaseAuth != null) {
      _requireOnline();
      final user = _firebaseAuth.currentUser;
      if (user != null && user.email == email) {
        await user.updateDisplayName(name);
        await user.reload();
        state = _authStateFromFirebaseUser(_firebaseAuth.currentUser);
        return;
      }

      try {
        final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await credential.user?.updateDisplayName(name);
        await credential.user?.sendEmailVerification();
        state = _authStateFromFirebaseUser(_firebaseAuth.currentUser);
      } catch (e) {
        throw Exception(firebaseAuthErrorMessage(e));
      }
      return;
    }

    await signIn(email: email, password: password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    state = state.copyWith(displayName: name);
  }

  Future<void> createPendingAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    if (_firebaseAuth == null) return;

    _requireOnline();
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await credential.user?.sendEmailVerification();
      state = _authStateFromFirebaseUser(_firebaseAuth.currentUser);
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    if (_firebaseAuth != null) {
      await _googleSignIn?.signOut();
      await _firebaseAuth.signOut();
      state = const AuthState(isInitialized: true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_passwordKey);
    state = const AuthState(isInitialized: true);
  }

  Future<bool> verifyCurrentPassword(String password) async {
    if (_firebaseAuth != null) {
      _requireOnline();
      final user = _firebaseAuth.currentUser;
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

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_passwordKey);
    if (stored == null || stored.isEmpty) return password.isNotEmpty;
    return stored == password;
  }

  Future<void> sendOtp({required String email}) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Informe um e-mail válido');
    }

    if (_firebaseAuth != null) {
      _requireOnline();
      final user = _firebaseAuth.currentUser;
      if (user != null && user.email == email) {
        await user.sendEmailVerification();
        return;
      }
      throw Exception('Crie a conta antes de verificar o e-mail');
    }

    await Future<void>.delayed(_mockOtpDelay);
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Informe um e-mail válido');
    }

    if (_firebaseAuth != null) {
      _requireOnline();
      try {
        await _firebaseAuth.sendPasswordResetEmail(email: email);
      } catch (e) {
        throw Exception(firebaseAuthErrorMessage(e));
      }
      return;
    }

    await Future<void>.delayed(_mockOtpDelay);
  }

  Future<bool> verifyOtp({required String email, required String code}) async {
    if (email.isEmpty) return false;

    if (_firebaseAuth != null) {
      _requireOnline();
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email != email) return false;
      await user.reload();
      final refreshed = _firebaseAuth.currentUser;
      return refreshed?.emailVerified ?? false;
    }

    await Future<void>.delayed(_mockOtpDelay);
    return code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code);
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    if (newPassword.length < 6) {
      throw Exception('A senha deve ter pelo menos 6 caracteres');
    }

    if (_firebaseAuth != null) {
      throw Exception('Use o link enviado por e-mail para redefinir a senha');
    }

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
      throw Exception('Faça login para alterar a senha');
    }

    if (newPassword.length < 6) {
      throw Exception('A senha deve ter pelo menos 6 caracteres');
    }

    if (_firebaseAuth != null) {
      _requireOnline();
      final user = _firebaseAuth.currentUser;
      final email = user?.email;
      if (user == null || email == null) {
        throw Exception('Sessão inválida');
      }

      try {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      } catch (e) {
        throw Exception(firebaseAuthErrorMessage(e));
      }
      return;
    }

    final valid = await verifyCurrentPassword(currentPassword);
    if (!valid) {
      throw Exception('Senha atual incorreta');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, newPassword);
  }

  Future<void> signInWithGoogle() async {
    if (_firebaseAuth == null || _googleSignIn == null) {
      throw Exception('Login com Google indisponível');
    }

    _requireOnline();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
      state = _authStateFromFirebaseUser(_firebaseAuth.currentUser);
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> signInWithApple() async {
    if (_firebaseAuth == null) {
      throw Exception('Login com Apple indisponível');
    }

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw Exception('Login com Apple disponível apenas no iOS');
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
      await _firebaseAuth.signInWithCredential(oauthCredential);
      state = _authStateFromFirebaseUser(_firebaseAuth.currentUser);
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final bootstrap = ref.watch(firebaseBootstrapProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  if (bootstrap.isAvailable) {
    return AuthNotifier(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: FirebaseAuthConfig.createGoogleSignIn(),
      connectivity: connectivity,
    );
  }
  return AuthNotifier(connectivity: connectivity);
});
