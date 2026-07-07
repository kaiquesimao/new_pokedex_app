import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';
import 'package:pokedex_app/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('PasswordPolicy', () {
    test('accepts valid lengths', () {
      expect(PasswordPolicy.validateWithL10n(l10n, 'abcdef'), isNull);
      expect(
        PasswordPolicy.validateWithL10n(l10n, 'a' * PasswordPolicy.maxLength),
        isNull,
      );
    });

    test('rejects too short passwords', () {
      expect(
        PasswordPolicy.validateWithL10n(l10n, '12345'),
        l10n.authPasswordTooShort(PasswordPolicy.minLength),
      );
    });

    test('rejects too long passwords', () {
      expect(
        PasswordPolicy.validateWithL10n(
          l10n,
          'a' * (PasswordPolicy.maxLength + 1),
        ),
        l10n.authPasswordTooLong(PasswordPolicy.maxLength),
      );
    });
  });
}
