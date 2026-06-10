import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const onboardingCompletedKey = 'onboarding_completed';

bool readOnboardingCompleted(SharedPreferences prefs) {
  return prefs.getBool(onboardingCompletedKey) ?? false;
}

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(super.completed);

  Future<void> complete() async {
    if (state) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompletedKey, true);
    state = true;
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
      return OnboardingNotifier(false);
    });
