import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/firebase_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthNotifier OTP', () {
    test('verifyOtp accepts six digit code', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [
          firebaseUnavailableOverride,
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final valid = await container
          .read(authProvider.notifier)
          .verifyOtp(email: 'ash@pokemon.com', code: '123456');

      expect(valid, isTrue);
    });

    test('verifyOtp rejects invalid code', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [
          firebaseUnavailableOverride,
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final valid = await container
          .read(authProvider.notifier)
          .verifyOtp(email: 'ash@pokemon.com', code: '12345');

      expect(valid, isFalse);
    });

    test('resetPassword updates stored password for known email', () async {
      SharedPreferences.setMockInitialValues({
        'mock_auth_session': true,
        'mock_auth_email': 'ash@pokemon.com',
        'mock_auth_name': 'Ash',
        'mock_auth_password': 'oldpass',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer.test(
        overrides: [
          firebaseUnavailableOverride,
          sharedPreferencesProvider.overrideWithValue(prefs),
          authProvider.overrideWithBuild(
            (ref, notifier) => readStoredAuthState(prefs),
          ),
        ],
      );

      await container
          .read(authProvider.notifier)
          .resetPassword(email: 'ash@pokemon.com', newPassword: 'newpass123');

      expect(
        await container
            .read(authProvider.notifier)
            .verifyCurrentPassword('newpass123'),
        isTrue,
      );
    });
  });
}
