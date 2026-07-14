import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:pokedex_app/core/env/env.dart';

/// Firebase options loaded from compile-time environment variables.
///
/// Provide values via `--dart-define-from-file=dart_defines.json` (see
/// `dart_defines.example.json`).
class DefaultFirebaseOptions {
  static bool get isConfigured => Env.isFirebaseConfigured;

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw StateError(
        'Firebase is not configured. Copy dart_defines.example.json to '
        'dart_defines.json and run with '
        '--dart-define-from-file=dart_defines.json',
      );
    }
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for fuchsia.',
        );
    }
  }

  /// Web options. Google Sign-In is not offered on web (Wasm COOP/COEP);
  /// email/password Auth uses [Env.webAuthDomain].
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: Env.webApiKey,
    appId: Env.webAppId,
    messagingSenderId: Env.messagingSenderId,
    projectId: Env.projectId,
    authDomain: Env.webAuthDomain,
    storageBucket: Env.storageBucket,
    measurementId: Env.webMeasurementId,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: Env.androidApiKey,
    appId: Env.androidAppId,
    messagingSenderId: Env.messagingSenderId,
    projectId: Env.projectId,
    storageBucket: Env.storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: Env.iosApiKey,
    appId: Env.iosAppId,
    messagingSenderId: Env.messagingSenderId,
    projectId: Env.projectId,
    storageBucket: Env.storageBucket,
    iosBundleId: Env.iosBundleId,
  );
}
