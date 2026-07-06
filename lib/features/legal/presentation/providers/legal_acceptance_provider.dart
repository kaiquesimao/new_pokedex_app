import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const legalTermsAcceptedKey = 'legal_terms_accepted';

bool readLegalTermsAccepted(SharedPreferences prefs) {
  return prefs.getBool(legalTermsAcceptedKey) ?? false;
}

class LegalAcceptanceNotifier extends Notifier<bool> {
  @override
  bool build() => readLegalTermsAccepted(ref.watch(sharedPreferencesProvider));

  Future<void> accept() async {
    if (state) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(legalTermsAcceptedKey, true);
    state = true;
  }
}

final legalAcceptanceProvider = NotifierProvider<LegalAcceptanceNotifier, bool>(
  LegalAcceptanceNotifier.new,
);

/// Ephemeral checkbox state on auth/onboarding screens before persistence.
class LegalAcceptanceDraftNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(legalAcceptanceProvider);

  void setChecked({required bool value}) {
    if (ref.read(legalAcceptanceProvider)) return;
    state = value;
  }
}

final legalAcceptanceDraftProvider =
    NotifierProvider<LegalAcceptanceDraftNotifier, bool>(
      LegalAcceptanceDraftNotifier.new,
    );
