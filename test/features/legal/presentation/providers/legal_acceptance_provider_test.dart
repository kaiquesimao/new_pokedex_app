import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/legal/presentation/providers/legal_acceptance_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LegalAcceptanceNotifier', () {
    test('readLegalTermsAccepted returns false by default', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(readLegalTermsAccepted(prefs), isFalse);
    });

    test('accept persists legal_terms_accepted flag', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      await container.read(legalAcceptanceProvider.notifier).accept();

      expect(container.read(legalAcceptanceProvider), isTrue);
      expect(readLegalTermsAccepted(prefs), isTrue);
    });
  });
}
