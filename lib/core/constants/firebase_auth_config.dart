import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase / Google Sign-In constants from `google-services.json`.
abstract final class FirebaseAuthConfig {
  /// Web client ID (`client_type: 3`) — required on Android for Firebase Auth idToken.
  static const String googleWebClientId =
      '1067718010231-qtat7muck82ubmv8dig0jomsg7i00j3a.apps.googleusercontent.com';

  static Completer<void>? _googleSignInInit;

  /// Lazily initializes [GoogleSignIn.instance] before the first OAuth flow.
  static Future<void> ensureGoogleSignInInitialized() {
    final pending = _googleSignInInit;
    if (pending != null) {
      return pending.future;
    }

    final completer = Completer<void>();
    _googleSignInInit = completer;
    unawaited(
      GoogleSignIn.instance
          .initialize(
            clientId: kIsWeb ? googleWebClientId : null,
            serverClientId: kIsWeb ? null : googleWebClientId,
          )
          .then(completer.complete)
          .onError<Object>((error, stack) {
            _googleSignInInit = null;
            completer.completeError(error, stack);
          }),
    );
    return completer.future;
  }
}
