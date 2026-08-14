import 'package:in_app_review/in_app_review.dart';
import 'package:pokedex_app/features/reviews/domain/app_review_service.dart';

/// Play Store listing and in-app review via `package:in_app_review`.
class PlayAppReviewService implements AppReviewService {
  new({InAppReview? inAppReview})
    : _inAppReview = inAppReview ?? InAppReview.instance;

  final InAppReview _inAppReview;

  @override
  Future<bool> requestInAppReviewIfAvailable() async {
    if (!await _inAppReview.isAvailable()) return false;
    await _inAppReview.requestReview();
    return true;
  }

  @override
  Future<void> rateFromSettings() async {
    if (await requestInAppReviewIfAvailable()) return;
    await _inAppReview.openStoreListing();
  }
}
