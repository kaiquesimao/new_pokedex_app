import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/auth/domain/display_name_policy.dart';

void main() {
  group('DisplayNamePolicy', () {
    test('accepts non-empty trimmed name', () {
      expect(DisplayNamePolicy.validate('  Ash  '), isNull);
    });

    test('rejects empty name', () {
      expect(DisplayNamePolicy.validate('   '), 'Informe um nome');
    });

    test('rejects name longer than max length', () {
      expect(
        DisplayNamePolicy.validate('a' * (DisplayNamePolicy.maxLength + 1)),
        isNotNull,
      );
    });
  });
}
