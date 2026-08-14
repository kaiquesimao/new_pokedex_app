/// Opens the in-app review flow or the public store listing.
abstract class AppReviewService {
  /// Shows the platform in-app review UI when the store allows it.
  ///
  /// Returns `true` when the request was sent to the platform.
  Future<bool> requestInAppReviewIfAvailable();

  /// Requests an in-app review, or opens the store listing as a fallback.
  Future<void> rateFromSettings();
}
