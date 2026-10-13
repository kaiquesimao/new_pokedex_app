import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/home_tutorial/domain/home_tutorial_step.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/providers/home_tutorial_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeTutorialNotifier', () {
    test('readHomeTutorialCompleted returns false by default', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(readHomeTutorialCompleted(prefs), isFalse);
    });

    test('tryAutoStart activates only when not completed', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      container.read(homeTutorialProvider.notifier).tryAutoStart();

      final state = container.read(homeTutorialProvider);
      expect(state.isActive, isTrue);
      expect(state.stepIndex, 0);
      expect(state.currentStep, HomeTutorialStepId.search);
    });

    test('tryAutoStart is a no-op when already completed', () async {
      SharedPreferences.setMockInitialValues({
        homeTutorialCompletedKey: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      container.read(homeTutorialProvider.notifier).tryAutoStart();

      expect(container.read(homeTutorialProvider).isActive, isFalse);
      expect(container.read(homeTutorialProvider).completed, isTrue);
    });

    test('next advances steps then complete persists flag', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      final notifier = container.read(homeTutorialProvider.notifier)
        ..tryAutoStart();

      for (var i = 0; i < HomeTutorialStepId.values.length - 1; i++) {
        await notifier.next();
        expect(container.read(homeTutorialProvider).stepIndex, i + 1);
      }

      await notifier.next();

      expect(container.read(homeTutorialProvider).isActive, isFalse);
      expect(container.read(homeTutorialProvider).completed, isTrue);
      expect(readHomeTutorialCompleted(prefs), isTrue);
    });

    test('skip marks tutorial completed', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      container.read(homeTutorialProvider.notifier).tryAutoStart();

      await container.read(homeTutorialProvider.notifier).skip();

      expect(container.read(homeTutorialProvider).completed, isTrue);
      expect(container.read(homeTutorialProvider).isActive, isFalse);
      expect(readHomeTutorialCompleted(prefs), isTrue);
    });

    test('replay clears completed and restarts tour', () async {
      SharedPreferences.setMockInitialValues({
        homeTutorialCompletedKey: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      await container.read(homeTutorialProvider.notifier).replay();

      final state = container.read(homeTutorialProvider);
      expect(state.completed, isFalse);
      expect(state.isActive, isTrue);
      expect(state.stepIndex, 0);
      expect(readHomeTutorialCompleted(prefs), isFalse);
    });
  });
}
