import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/auth/domain/auth_registration_config.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';

void main() {
  test('needsEmailVerification is false when verification is disabled', () {
    expect(AuthRegistrationConfig.requireEmailVerification, isFalse);

    const auth = AuthState(
      isInitialized: true,
      isAuthenticated: true,
      emailVerified: false,
    );

    expect(auth.needsEmailVerification, isFalse);
  });
}
