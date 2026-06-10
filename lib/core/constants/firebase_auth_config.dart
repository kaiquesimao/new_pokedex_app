import 'package:google_sign_in/google_sign_in.dart';

/// Firebase / Google Sign-In constants from `google-services.json`.
abstract final class FirebaseAuthConfig {
  /// Web client ID (`client_type: 3`) — required on Android for Firebase Auth idToken.
  static const String googleWebClientId =
      '1067718010231-qtat7muck82ubmv8dig0jomsg7i00j3a.apps.googleusercontent.com';

  static GoogleSignIn createGoogleSignIn() {
    return GoogleSignIn(
      serverClientId: googleWebClientId,
      scopes: const ['email'],
    );
  }
}
