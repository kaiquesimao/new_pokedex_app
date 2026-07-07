import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/data/firebase_auth_errors.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
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

  group('AuthNotifier credential edits', () {
    test('changePassword rejects social account', () async {
      final container = ProviderContainer.test(
        overrides: [
          firebaseUnavailableOverride,
          authProvider.overrideWithBuild(
            (ref, notifier) => const AuthState(
              isInitialized: true,
              isAuthenticated: true,
              canEditCredentials: false,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(authProvider.notifier)
            .changePassword(
              currentPassword: 'oldpass',
              newPassword: 'newpass123',
            ),
        throwsA(isA<AuthException>()),
      );
    });

    test('verifyCurrentPassword rejects social account', () async {
      final container = ProviderContainer.test(
        overrides: [
          firebaseUnavailableOverride,
          authProvider.overrideWithBuild(
            (ref, notifier) => const AuthState(
              isInitialized: true,
              isAuthenticated: true,
              canEditCredentials: false,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(authProvider.notifier).verifyCurrentPassword('any'),
        throwsA(isA<AuthException>()),
      );
    });

    test('updateDisplayName updates mock auth display name', () async {
      SharedPreferences.setMockInitialValues({
        'mock_auth_session': true,
        'mock_auth_email': 'ash@pokemon.com',
        'mock_auth_name': 'Ash',
        'mock_auth_password': 'senha123',
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
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).updateDisplayName('Misty');

      expect(container.read(authProvider).displayName, 'Misty');
      expect(prefs.getString('mock_auth_name'), 'Misty');
    });

    test('updateDisplayName rejects empty name', () async {
      SharedPreferences.setMockInitialValues({
        'mock_auth_session': true,
        'mock_auth_email': 'ash@pokemon.com',
        'mock_auth_name': 'Ash',
        'mock_auth_password': 'senha123',
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
      addTearDown(container.dispose);

      await expectLater(
        container.read(authProvider.notifier).updateDisplayName('   '),
        throwsA(isA<AuthException>()),
      );
    });

    test('requestEmailChange stores pending email for mock auth', () async {
      SharedPreferences.setMockInitialValues({
        'mock_auth_session': true,
        'mock_auth_email': 'ash@pokemon.com',
        'mock_auth_name': 'Ash',
        'mock_auth_password': 'senha123',
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
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .requestEmailChange(
            currentPassword: 'senha123',
            newEmail: 'misty@pokemon.com',
          );

      expect(container.read(authProvider).email, 'ash@pokemon.com');
      expect(prefs.getString('mock_auth_pending_email'), 'misty@pokemon.com');
    });

    test('completeEmailChangeVerification updates mock email after otp', () async {
      SharedPreferences.setMockInitialValues({
        'mock_auth_session': true,
        'mock_auth_email': 'ash@pokemon.com',
        'mock_auth_name': 'Ash',
        'mock_auth_password': 'senha123',
        'mock_auth_pending_email': 'misty@pokemon.com',
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
      addTearDown(container.dispose);

      final verified = await container
          .read(authProvider.notifier)
          .completeEmailChangeVerification(
            expectedEmail: 'misty@pokemon.com',
            otpCode: '123456',
          );

      expect(verified, isTrue);
      expect(container.read(authProvider).email, 'misty@pokemon.com');
      expect(prefs.getString('mock_auth_email'), 'misty@pokemon.com');
    });

    test('requestEmailChange rejects social account', () async {
      final container = ProviderContainer.test(
        overrides: [
          firebaseUnavailableOverride,
          authProvider.overrideWithBuild(
            (ref, notifier) => const AuthState(
              isInitialized: true,
              isAuthenticated: true,
              canEditCredentials: false,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(authProvider.notifier)
            .requestEmailChange(
              currentPassword: 'any',
              newEmail: 'new@pokemon.com',
            ),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
