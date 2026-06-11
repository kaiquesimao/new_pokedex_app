import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';

void main() {
  group('firebaseAuthErrorMessage', () {
    test('maps invalid-credential for email sign-in to user-friendly text', () {
      final error = FirebaseAuthException(code: 'invalid-credential');

      final message = firebaseAuthErrorMessage(
        error,
        context: FirebaseAuthErrorContext.emailSignIn,
      );

      expect(message, contains('E-mail ou senha incorretos'));
      expect(message, isNot(contains('SHA-1')));
    });

    test('maps invalid-credential for oauth to config hint', () {
      final error = FirebaseAuthException(code: 'invalid-credential');

      final message = firebaseAuthErrorMessage(
        error,
        context: FirebaseAuthErrorContext.oauth,
      );

      expect(message, contains('SHA-1'));
    });

    test('maps email-already-in-use for sign-up with social hint', () {
      final error = FirebaseAuthException(code: 'email-already-in-use');

      final message = firebaseAuthErrorMessage(
        error,
        context: FirebaseAuthErrorContext.emailSignUp,
      );

      expect(message, contains('Google'));
    });
  });

  group('emailAlreadyInUseMessage', () {
    test('mentions Google when account uses Google', () {
      expect(
        emailAlreadyInUseMessage(signInMethods: ['google.com']),
        contains('Google'),
      );
    });
  });

  group('formatAuthException', () {
    test('returns AuthException message directly', () {
      expect(
        formatAuthException(AuthException('Este e-mail já está em uso.')),
        'Este e-mail já está em uso.',
      );
    });

    test('strips legacy Exception prefix', () {
      expect(
        formatAuthException(Exception('E-mail ou senha incorretos.')),
        'E-mail ou senha incorretos.',
      );
    });
  });
}
