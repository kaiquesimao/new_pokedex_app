import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/shared/widgets/otp_code_field.dart';

void main() {
  testWidgets('OtpCodeField renders six digit boxes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpCodeField(onCompleted: (_) {}),
        ),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(6));
    expect(find.text('Reenviar código'), findsNothing);
  });

  testWidgets('OtpCodeField shows resend link when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpCodeField(
            onCompleted: (_) {},
            onResend: () {},
          ),
        ),
      ),
    );

    expect(find.text('Reenviar código'), findsOneWidget);
  });
}
