import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/auth/domain/auth_account_policy.dart';

void main() {
  group('accountCanEditCredentials', () {
    test('allows password-only account', () {
      expect(accountCanEditCredentials(['password']), isTrue);
    });

    test('allows linked password and Google account', () {
      expect(
        accountCanEditCredentials(['password', 'google.com']),
        isTrue,
      );
    });

    test('denies Google-only account', () {
      expect(accountCanEditCredentials(['google.com']), isFalse);
    });

    test('denies Apple-only account', () {
      expect(accountCanEditCredentials(['apple.com']), isFalse);
    });

    test('treats empty providers as password account (mock auth)', () {
      expect(accountCanEditCredentials([]), isTrue);
    });
  });
}
