import 'package:flutter_test/flutter_test.dart';
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
      final notifier = OnboardingNotifier(false);

      await notifier.complete();

      expect(notifier.state, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(readOnboardingCompleted(prefs), isTrue);
    });
  });
}
