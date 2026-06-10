import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthNotifier OTP', () {
    test('verifyOtp accepts six digit code', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = AuthNotifier();

      final valid = await notifier.verifyOtp(
        email: 'ash@pokemon.com',
        code: '123456',
      );

      expect(valid, isTrue);
    });

    test('verifyOtp rejects invalid code', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = AuthNotifier();

      final valid = await notifier.verifyOtp(
        email: 'ash@pokemon.com',
        code: '12345',
      );

      expect(valid, isFalse);
    });

    test('resetPassword updates stored password for known email', () async {
      SharedPreferences.setMockInitialValues({
        'mock_auth_session': true,
        'mock_auth_email': 'ash@pokemon.com',
        'mock_auth_name': 'Ash',
        'mock_auth_password': 'oldpass',
      });
      final notifier = AuthNotifier();

      await notifier.resetPassword(
        email: 'ash@pokemon.com',
        newPassword: 'newpass123',
      );

      expect(await notifier.verifyCurrentPassword('newpass123'), isTrue);
    });
  });
}
