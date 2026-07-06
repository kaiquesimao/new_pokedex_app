import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/bootstrap/app_bootstrap.dart';

void main() {
  group('resolveInitialLocation', () {
    test('routes to onboarding when not completed', () {
      expect(
        resolveInitialLocation(
          onboardingCompleted: false,
          legalTermsAccepted: false,
          isAuthenticated: true,
        ),
        '/onboarding',
      );
    });

    test('routes to welcome when terms not accepted', () {
      expect(
        resolveInitialLocation(
          onboardingCompleted: true,
          legalTermsAccepted: false,
          isAuthenticated: true,
        ),
        '/welcome',
      );
    });

    test('routes to pokedex when authenticated and terms accepted', () {
      expect(
        resolveInitialLocation(
          onboardingCompleted: true,
          legalTermsAccepted: true,
          isAuthenticated: true,
        ),
        '/pokedex',
      );
    });

    test('routes to welcome when guest with terms accepted', () {
      expect(
        resolveInitialLocation(
          onboardingCompleted: true,
          legalTermsAccepted: true,
          isAuthenticated: false,
        ),
        '/welcome',
      );
    });
  });
}
