import 'package:url_launcher/url_launcher.dart';

/// External voluntary-support destinations for PokeData.
///
/// Provider (POK-41): **Ko-fi** — one-time tips, no paywall, no in-app purchases.
/// Change [donationUri] if the maintainer prefers another tip jar (Pix link,
/// Buy Me a Coffee, GitHub Sponsors once enabled, etc.).
abstract final class AppSupportLinks {
  /// Public Ko-fi page for optional donations.
  ///
  /// Claim or create this page before release, or replace with another URL.
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
