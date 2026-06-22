import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/login_email_form_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/firebase_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginEmailFormNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer.test(
        overrides: [
          firebaseUnavailableOverride,
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('submit sets error when password is empty', () async {
      final notifier = container.read(loginEmailFormProvider.notifier);

      await notifier.submit(
        email: 'ash@pokemon.com',
        password: '',
      );

      expect(container.read(loginEmailFormProvider).error, isNotNull);
      expect(container.read(loginEmailFormProvider).loading, isFalse);
    });

    test('submit clears error and sets loading during call', () async {
      final notifier = container.read(loginEmailFormProvider.notifier);

      final future = notifier.submit(
        email: 'ash@pokemon.com',
        password: 'senha123',
      );

      expect(container.read(loginEmailFormProvider).loading, isTrue);
      await future;
      expect(container.read(loginEmailFormProvider).loading, isFalse);
    });
  });
}
