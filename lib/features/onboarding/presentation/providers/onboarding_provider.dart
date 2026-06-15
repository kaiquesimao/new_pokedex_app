import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const onboardingCompletedKey = 'onboarding_completed';

bool readOnboardingCompleted(SharedPreferences prefs) {
  return prefs.getBool(onboardingCompletedKey) ?? false;
}

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => readOnboardingCompleted(ref.watch(sharedPreferencesProvider));

  Future<void> complete() async {
    if (state) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompletedKey, true);
    state = true;
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);
