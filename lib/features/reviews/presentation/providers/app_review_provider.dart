import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/reviews/data/play_app_review_service.dart';
import 'package:pokedex_app/features/reviews/domain/app_review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const inAppReviewPromptedKey = 'in_app_review_prompted';

/// Coordinates when to ask for a Play Store review.
class AppReviewController {
  AppReviewController({
    required this.prefs,
    required this.service,
  });

  final SharedPreferences prefs;
  final AppReviewService service;

  /// Settings row: in-app review, or the public listing if unavailable.
  Future<void> rateFromSettings() => service.rateFromSettings();

  /// One-shot in-app prompt after a positive action (adding a favorite).
  Future<void> maybeRequestAfterFavorite() async {
    if (prefs.getBool(inAppReviewPromptedKey) ?? false) return;
    final shown = await service.requestInAppReviewIfAvailable();
    if (!shown) return;
    await prefs.setBool(inAppReviewPromptedKey, true);
  }
}

final appReviewServiceProvider = Provider<AppReviewService>(
  (ref) => PlayAppReviewService(),
);

final appReviewControllerProvider = Provider<AppReviewController>((ref) {
  return AppReviewController(
    prefs: ref.watch(sharedPreferencesProvider),
    service: ref.watch(appReviewServiceProvider),
  );
});
