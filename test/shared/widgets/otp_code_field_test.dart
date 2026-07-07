import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/shared/widgets/otp_code_field.dart';

import '../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('OtpCodeField renders six digit boxes', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: const Scaffold(
        body: OtpCodeField(onCompleted: _onCompleted),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(6));
    expect(find.text('Reenviar código'), findsNothing);
  });

  testWidgets('OtpCodeField shows resend link when provided', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: const Scaffold(
        body: OtpCodeField(
          onCompleted: _onCompleted,
          onResend: _onResend,
        ),
      ),
    );

    expect(find.text('Reenviar código'), findsOneWidget);
  });
}

void _onCompleted(String _) {}

void _onResend() {}
