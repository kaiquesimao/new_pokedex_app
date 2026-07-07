import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/l10n/generated/app_localizations_pt.dart';

void main() {
  final l10n = AppLocalizationsPt();

  group('firebaseAuthErrorMessage', () {
    test('maps invalid-credential for email sign-in to user-friendly text', () {
      final message = firebaseAuthErrorMessage(l10n, 'invalid-credential');

      expect(message, contains('E-mail ou senha incorretos'));
      expect(message, isNot(contains('SHA-1')));
    });

    test('maps invalid-credential for oauth to config hint', () {
      final message = firebaseAuthErrorMessage(
        l10n,
        'invalid-credential-oauth',
      );

      expect(message, contains('SHA-1'));
    });

    test('maps email-already-in-use for sign-up with social hint', () {
      final message = firebaseAuthErrorMessage(l10n, 'email-already-in-use');

      expect(message, contains('Este e-mail'));
    });
  });

  group('emailAlreadyInUseMessage', () {
    test('mentions Google when account uses Google', () {
      expect(
        emailAlreadyInUseMessage(l10n, signInMethods: ['google.com']),
        contains('Google'),
      );
    });
  });

  group('formatAuthException', () {
    test('returns AuthException message directly', () {
      expect(
        formatAuthException(l10n, AuthException('Este e-mail já está em uso.')),
        'Este e-mail já está em uso.',
      );
    });

    test('formatAuthException maps FirebaseAuthException via l10n', () {
      final ptL10n = lookupAppLocalizations(const Locale('pt', 'BR'));
      final err = FirebaseAuthException(code: 'wrong-password');
      expect(
        formatAuthException(ptL10n, err),
        ptL10n.authWrongPassword,
      );
    });

    test('formatAuthException hides generic Exception', () {
      final enL10n = lookupAppLocalizations(const Locale('en', 'US'));
      expect(
        formatAuthException(enL10n, Exception('raw sdk noise')),
        enL10n.authGenericError,
      );
    });
  });
}
