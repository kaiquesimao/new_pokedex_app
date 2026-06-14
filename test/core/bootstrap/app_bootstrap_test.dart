import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/bootstrap/app_bootstrap.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';

void main() {
  group('resolveInitialLocation', () {
    test('routes to onboarding when not completed', () {
      expect(
        resolveInitialLocation(
          onboardingCompleted: false,
          auth: const AuthState(isInitialized: true, isAuthenticated: true),
        ),
        '/onboarding',
      );
    });

    test('routes to pokedex when authenticated', () {
      expect(
        resolveInitialLocation(
          onboardingCompleted: true,
          auth: const AuthState(isInitialized: true, isAuthenticated: true),
        ),
        '/pokedex',
      );
    });

    test('routes to welcome when guest', () {
      expect(
        resolveInitialLocation(
          onboardingCompleted: true,
          auth: const AuthState(isInitialized: true),
        ),
        '/welcome',
      );
    });
  });
}
