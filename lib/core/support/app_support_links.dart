import 'package:url_launcher/url_launcher.dart';

/// External voluntary-support destinations for PokeData.
///
/// Provider (POK-41): **Ko-fi only** — one-time tips, no ads, no paywall, no IAP.
/// Pix and other methods are deferred; do not add them here until product asks.
abstract final class AppSupportLinks {
  /// Confirmed public Ko-fi page for optional donations.
  static final Uri donationUri = Uri.parse('https://ko-fi.com/kaiquesimao');

  /// Opens [donationUri] in an external browser / custom tab.
  ///
  /// Returns `true` when a handler accepted the URL. Pass [launch] in tests.
  static Future<bool> openDonationPage({
    Future<bool> Function(Uri uri, {LaunchMode mode})? launch,
  }) async {
    final launcher = launch ?? launchUrl;
    return launcher(donationUri, mode: LaunchMode.externalApplication);
  }
}
