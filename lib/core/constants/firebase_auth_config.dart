import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn;
import 'package:pokedex_app/core/env/env.dart' show Env;

/// Google Sign-In setup using compile-time env (`FIREBASE_GOOGLE_WEB_CLIENT_ID`).
abstract final class FirebaseAuthConfig {
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
            clientId: kIsWeb ? Env.googleWebClientId : null,
            serverClientId: kIsWeb ? null : Env.googleWebClientId,
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
