import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/change_email_flow_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/firebase_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChangeEmailFlowNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'mock_auth_session': true,
        'mock_auth_email': 'ash@pokemon.com',
        'mock_auth_name': 'Ash',
        'mock_auth_password': 'senha123',
      });
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer.test(
        overrides: [
          firebaseUnavailableOverride,
          sharedPreferencesProvider.overrideWithValue(prefs),
          authProvider.overrideWithBuild(
            (ref, notifier) => readStoredAuthState(prefs),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('full flow updates email after otp verification', () async {
      final sub = container.listen(
        changeEmailFlowProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      final notifier = container.read(changeEmailFlowProvider.notifier);

      await notifier.submitCurrentPassword('senha123');
      expect(
        container.read(changeEmailFlowProvider).step,
        ChangeEmailStep.newEmail,
      );

      await notifier.submitNewEmail('misty@pokemon.com');
      expect(
        container.read(changeEmailFlowProvider).step,
        ChangeEmailStep.verify,
      );

      await notifier.submitVerification(otpCode: '123456');
      expect(
        container.read(changeEmailFlowProvider).step,
        ChangeEmailStep.success,
      );
      expect(container.read(authProvider).email, 'misty@pokemon.com');
    });
  });
}
