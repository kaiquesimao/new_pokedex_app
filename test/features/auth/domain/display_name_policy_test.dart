import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/auth/domain/display_name_policy.dart';
import 'package:pokedex_app/l10n/generated/app_localizations_pt.dart';

void main() {
  final l10n = AppLocalizationsPt();

  group('DisplayNamePolicy', () {
    test('accepts trimmed valid names', () {
      expect(DisplayNamePolicy.validateWithL10n(l10n, '  Ash  '), isNull);
    });

    test('rejects empty names', () {
      expect(
        DisplayNamePolicy.validateWithL10n(l10n, '   '),
        l10n.authEnterYourName,
      );
    });

    test('rejects names over max length', () {
      expect(
        DisplayNamePolicy.validateWithL10n(
          l10n,
          'a' * (DisplayNamePolicy.maxLength + 1),
        ),
        l10n.authDisplayNameTooLong(DisplayNamePolicy.maxLength),
      );
    });
  });
}
