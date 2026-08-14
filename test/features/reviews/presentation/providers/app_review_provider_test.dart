import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/reviews/domain/app_review_service.dart';
import 'package:pokedex_app/features/reviews/presentation/providers/app_review_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeReviewService implements AppReviewService {
  _FakeReviewService({this.inAppAvailable = true});

  bool inAppAvailable;
  int inAppCalls = 0;
  int settingsCalls = 0;

  @override
  Future<bool> requestInAppReviewIfAvailable() async {
    inAppCalls++;
    return inAppAvailable;
  }

  @override
  Future<void> rateFromSettings() async {
    settingsCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppReviewController', () {
    test('prompts in-app review once after a favorite', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = _FakeReviewService();
      final controller = AppReviewController(
        prefs: prefs,
        service: service,
      );

      await controller.maybeRequestAfterFavorite();
      await controller.maybeRequestAfterFavorite();

      expect(service.inAppCalls, 1);
      expect(prefs.getBool(inAppReviewPromptedKey), isTrue);
    });

    test('retries when in-app review is unavailable', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = _FakeReviewService(inAppAvailable: false);
      final controller = AppReviewController(
        prefs: prefs,
        service: service,
      );

      await controller.maybeRequestAfterFavorite();
      await controller.maybeRequestAfterFavorite();

      expect(service.inAppCalls, 2);
      expect(prefs.getBool(inAppReviewPromptedKey), isNull);
    });

    test('rateFromSettings delegates to the service', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = _FakeReviewService();
      final controller = AppReviewController(
        prefs: prefs,
        service: service,
      );

      await controller.rateFromSettings();

      expect(service.settingsCalls, 1);
    });
  });

  test('appReviewControllerProvider uses injected service', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = _FakeReviewService();
    final container = ProviderContainer.test(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appReviewServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appReviewControllerProvider).rateFromSettings();
    expect(service.settingsCalls, 1);
  });
}
