import 'package:firebase_auth/firebase_auth.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';

enum FirebaseAuthErrorContext { emailSignIn, emailSignUp, oauth, general }

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

String firebaseAuthErrorMessageFromException(
  AppLocalizations l10n,
  Object error, {
  FirebaseAuthErrorContext context = FirebaseAuthErrorContext.general,
}) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => l10n.authInvalidEmail,
      'user-disabled' => l10n.authUserDisabled,
      'user-not-found' => switch (context) {
        FirebaseAuthErrorContext.emailSignIn => l10n.authUserNotFoundSignIn,
        _ => l10n.authUserNotFound,
      },
      'wrong-password' => l10n.authWrongPassword,
      'email-already-in-use' => switch (context) {
        FirebaseAuthErrorContext.emailSignUp => emailAlreadyInUseMessage(l10n),
        _ => l10n.authEmailAlreadyInUse,
      },
      'weak-password' => PasswordPolicy.requirementsHintOf(l10n),
      'too-many-requests' => l10n.authTooManyRequests,
      'network-request-failed' => l10n.authNetworkRequestFailed,
      'requires-recent-login' => l10n.authRequiresRecentLogin,
      'invalid-credential' => switch (context) {
        FirebaseAuthErrorContext.emailSignIn =>
          l10n.authInvalidCredentialEmailSignIn,
        FirebaseAuthErrorContext.oauth => l10n.authInvalidCredentialOauth,
        _ => l10n.authInvalidCredentialsGeneric,
      },
      'account-exists-with-different-credential' =>
        l10n.authAccountExistsWithDifferentCredential,
      'operation-not-allowed' => l10n.authOperationNotAllowed,
      _ => l10n.authGenericError,
    };
  }
  return l10n.authGenericError;
}

/// New API: map a Firebase error code to a localized message using [l10n].
String firebaseAuthErrorMessageFromCode(AppLocalizations l10n, String code) {
  return firebaseAuthErrorMessageLocalized(l10n, code);
}

/// Required signature per task: firebaseAuthErrorMessage(AppLocalizations, String)
String firebaseAuthErrorMessage(AppLocalizations l10n, String code) {
  return firebaseAuthErrorMessageLocalized(l10n, code);
}

String firebaseAuthErrorMessageLocalized(AppLocalizations l10n, String code) {
  switch (code) {
    case 'invalid-email':
      return l10n.authInvalidEmail;
    case 'user-disabled':
      return l10n.authUserDisabled;
    case 'user-not-found':
      return l10n.authUserNotFoundSignIn;
    case 'wrong-password':
      return l10n.authWrongPassword;
    case 'email-already-in-use':
      return l10n.authEmailAlreadyInUse;
    case 'weak-password':
      return l10n.authWeakPassword;
    case 'too-many-requests':
      return l10n.authTooManyRequests;
    case 'network-request-failed':
      return l10n.authNetworkRequestFailed;
    case 'requires-recent-login':
      return l10n.authRequiresRecentLogin;
    case 'invalid-credential':
      return l10n.authInvalidCredentialEmailSignIn;
    case 'invalid-credential-oauth':
      return l10n.authInvalidCredentialOauth;
    case 'account-exists-with-different-credential':
      return l10n.authAccountExistsWithDifferentCredential;
    case 'operation-not-allowed':
      return l10n.authOperationNotAllowed;
    default:
      return l10n.authGenericError;
  }
}

String emailAlreadyInUseMessage(
  AppLocalizations l10n, {
  List<String> signInMethods = const [],
}) {
  if (signInMethods.contains('google.com')) {
    return l10n.authEmailAlreadyInUseGoogle;
  }
  if (signInMethods.contains('apple.com')) {
    return l10n.authEmailAlreadyInUseApple;
  }
  if (signInMethods.contains('password')) {
    return l10n.authEmailAlreadyInUseSignIn;
  }
  return l10n.authEmailAlreadyInUseTrySocial;
}

String formatAuthException(AppLocalizations l10n, Object error) {
  if (error is AuthException) return error.message;
  if (error is FirebaseAuthException) {
    return firebaseAuthErrorMessageFromException(l10n, error);
  }
  return l10n.authGenericError;
}
