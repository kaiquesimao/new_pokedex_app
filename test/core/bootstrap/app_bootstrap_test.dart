import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/bootstrap/app_bootstrap.dart';

void main() {
  group('resolveInitialLocation', () {
    test('routes to onboarding when not completed', () {
      expect(
        resolveInitialLocation(
          onboardingCompleted: false,
          isAuthenticated: true,
        ),
        '/onboarding',
      );
    });

    test('routes to pokedex when authenticated', () {
      expect(
        resolveInitialLocation(
          onboardingCompleted: true,
          isAuthenticated: true,
        ),
        '/pokedex',
      );
    });

    test('routes to welcome when guest', () {
      expect(
        resolveInitialLocation(
          onboardingCompleted: true,
          isAuthenticated: false,
        ),
        '/welcome',
      );
    });
  });
}
