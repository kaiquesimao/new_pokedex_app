/// Result of asking the user to start an in-app update.
enum AppUpdateUserResult {
  /// User accepted; for flexible updates the download finished.
  success,

  /// User dismissed or cancelled the Play update UI.
  denied,

  /// Play reported a failure (or the API is unavailable).
  failed,

  /// No update / not supported on this platform or install source.
  unavailable,
}

/// Snapshot of Play In-App Update availability (Android only).
class const AppUpdateAvailabilityInfo({
  required final bool updateAvailable,
  required final bool flexibleAllowed,
  required final bool immediateAllowed,
  required final bool alreadyDownloaded,
  final int? availableVersionCode,
});

/// Platform bridge for Google Play In-App Updates.
abstract class AppUpdateService {
  /// Checks whether Play has an update for this install.
  ///
  /// Returns `null` when the API is unavailable (debug/sideload/non-Android).
  Future<AppUpdateAvailabilityInfo?> checkForUpdate();

  /// Starts a flexible (background) update download.
  Future<AppUpdateUserResult> startFlexibleUpdate();

  /// Applies a previously downloaded flexible update (restarts the app).
  Future<void> completeFlexibleUpdate();

  /// Starts a blocking immediate update (full-screen Play UI).
  Future<AppUpdateUserResult> performImmediateUpdate();
}
