import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingNotifier', () {
    test('readOnboardingCompleted returns false by default', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(readOnboardingCompleted(prefs), isFalse);
    });

    test('complete persists onboarding_completed flag', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      await container.read(onboardingProvider.notifier).complete();

      expect(container.read(onboardingProvider), isTrue);
      expect(readOnboardingCompleted(prefs), isTrue);
    });
  });
}
