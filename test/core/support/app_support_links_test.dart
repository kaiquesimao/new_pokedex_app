import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/support/app_support_links.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  group('AppSupportLinks', () {
    test('donationUri points at the Ko-fi tip jar', () {
      expect(AppSupportLinks.donationUri.scheme, 'https');
      expect(AppSupportLinks.donationUri.host, 'ko-fi.com');
      expect(AppSupportLinks.donationUri.path, '/kaiquesimao');
    });

    test('openDonationPage launches the donation URI externally', () async {
      Uri? launchedUri;
      LaunchMode? launchedMode;

      final opened = await AppSupportLinks.openDonationPage(
        launch: (uri, {mode = LaunchMode.platformDefault}) async {
          launchedUri = uri;
          launchedMode = mode;
          return true;
        },
      );

      expect(opened, isTrue);
      expect(launchedUri, AppSupportLinks.donationUri);
      expect(launchedMode, LaunchMode.externalApplication);
    });

    test('openDonationPage returns false when launch fails', () async {
      final opened = await AppSupportLinks.openDonationPage(
        launch: (uri, {mode = LaunchMode.platformDefault}) async => false,
      );

      expect(opened, isFalse);
    });
  });
}
