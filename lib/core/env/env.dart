/// Compile-time environment values from `--dart-define` /
/// `--dart-define-from-file`.
abstract final class Env {
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  static const String webApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
  );
  static const String webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const String googleWebClientId = String.fromEnvironment(
    'FIREBASE_GOOGLE_WEB_CLIENT_ID',
  );
  static const String webAuthDomain = String.fromEnvironment(
    'FIREBASE_WEB_AUTH_DOMAIN',
  );
  static const String webMeasurementId = String.fromEnvironment(
    'FIREBASE_WEB_MEASUREMENT_ID',
  );

  static const String androidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
  );
  static const String androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );

  static const String iosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
  );
  static const String iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const String iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
  );

  static const String gameApiBaseUrl = String.fromEnvironment(
    'GAME_API_BASE_URL',
  );

  /// Sentry DSN for crash reporting (Android + web). Empty disables Sentry.
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// When > 0 and the installed Android `versionCode` is below this value,
  /// prefer a blocking immediate Play in-app update (POK-68 hook).
  /// Default 0 = never force immediate; flexible updates remain the default.
  static const int androidMinRequiredVersionCode = int.fromEnvironment(
    'ANDROID_MIN_REQUIRED_VERSION_CODE',
  );

  static bool get isFirebaseConfigured => projectId.isNotEmpty;
}
