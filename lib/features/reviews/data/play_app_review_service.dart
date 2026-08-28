import 'package:in_app_review/in_app_review.dart';
import 'package:pokedex_app/features/reviews/domain/app_review_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Play Store listing and in-app review via `package:in_app_review`.
class PlayAppReviewService implements AppReviewService {
  new({InAppReview? inAppReview})
    : _inAppReview = inAppReview ?? InAppReview.instance;

  static const androidPackageId = 'com.kaiquesimao.pokedex';

  final InAppReview _inAppReview;

  @override
  Future<bool> requestInAppReviewIfAvailable() async {
    if (!await _inAppReview.isAvailable()) return false;
    await _inAppReview.requestReview();
    return true;
  }

  @override
  Future<void> rateFromSettings() async {
    // Explicit user action: open the public listing. In-app review often
    // completes without showing UI once the app is on the Play Store.
    final marketUri = Uri.parse(
      'market://details?id=$androidPackageId',
    );
    if (await canLaunchUrl(marketUri)) {
      final opened = await launchUrl(
        marketUri,
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    }

    await _inAppReview.openStoreListing();
  }
}
