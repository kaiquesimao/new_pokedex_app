/// Opens the in-app review flow or the public store listing.
abstract class AppReviewService {
  /// Shows the platform in-app review UI when the store allows it.
  ///
  /// Returns `true` when the request was sent to the platform.
  Future<bool> requestInAppReviewIfAvailable();

  /// Opens the public store listing for an explicit user-initiated rating.
  Future<void> rateFromSettings();
}
