import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/auth/domain/password_policy.dart';

void main() {
  group('PasswordPolicy', () {
    test('accepts password within Firebase limits', () {
      expect(PasswordPolicy.validate('abcdef'), isNull);
      expect(PasswordPolicy.validate('a' * PasswordPolicy.maxLength), isNull);
    });

    test('rejects password shorter than minimum', () {
      expect(
        PasswordPolicy.validate('12345'),
        'A senha deve ter pelo menos 6 caracteres.',
      );
    });

    test('rejects password longer than maximum', () {
      expect(
        PasswordPolicy.validate('a' * (PasswordPolicy.maxLength + 1)),
        'A senha deve ter no máximo 4096 caracteres.',
      );
    });
  });
}
