import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/router/auth_redirect.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';

void main() {
  const onboardingDone = true;
  const termsAccepted = true;

  AuthState authenticated({
    bool emailVerified = true,
  }) {
    return AuthState(
      isInitialized: true,
      isAuthenticated: true,
      emailVerified: emailVerified,
      email: 'ash@pokemon.com',
      displayName: 'Ash',
    );
  }

  group('resolveAuthRedirect', () {
    test(
      'verified user on register hub route goes to register success',
      () {
        expect(
          resolveAuthRedirect(
            auth: authenticated(),
            onboardingCompleted: onboardingDone,
            legalTermsAccepted: termsAccepted,
            path: '/register',
          ),
          '/register/success',
        );
      },
    );

    test(
      'verified user on verify-email route goes to register success',
      () {
        expect(
          resolveAuthRedirect(
            auth: authenticated(),
            onboardingCompleted: onboardingDone,
            legalTermsAccepted: termsAccepted,
            path: '/register/verify-email',
          ),
          '/register/success',
        );
      },
    );

    test(
      'verified user on register email route stays on wizard',
      () {
        expect(
          resolveAuthRedirect(
            auth: authenticated(),
            onboardingCompleted: onboardingDone,
            legalTermsAccepted: termsAccepted,
            path: '/register/email',
          ),
          isNull,
        );
      },
    );

    test(
      'unverified user is not blocked when verification is disabled',
      () {
        expect(
          resolveAuthRedirect(
            auth: authenticated(emailVerified: false),
            onboardingCompleted: onboardingDone,
            legalTermsAccepted: termsAccepted,
            path: '/pokedex',
          ),
          isNull,
        );
      },
    );

    test(
      'register success route stays visible for verified user',
      () {
        expect(
          resolveAuthRedirect(
            auth: authenticated(),
            onboardingCompleted: onboardingDone,
            legalTermsAccepted: termsAccepted,
            path: '/register/success',
          ),
          isNull,
        );
      },
    );

    test('guest can open legal terms route', () {
      expect(
        resolveAuthRedirect(
          auth: const AuthState(isInitialized: true),
          onboardingCompleted: onboardingDone,
          legalTermsAccepted: termsAccepted,
          path: '/legal/terms',
        ),
        isNull,
      );
    });

    test('guest can open legal privacy route', () {
      expect(
        resolveAuthRedirect(
          auth: const AuthState(isInitialized: true),
          onboardingCompleted: onboardingDone,
          legalTermsAccepted: termsAccepted,
          path: '/legal/privacy',
        ),
        isNull,
      );
    });

    test('legal terms route bypasses onboarding', () {
      expect(
        resolveAuthRedirect(
          auth: const AuthState(isInitialized: true),
          onboardingCompleted: false,
          legalTermsAccepted: false,
          path: '/legal/terms',
        ),
        isNull,
      );
    });

    test('legal privacy route bypasses onboarding', () {
      expect(
        resolveAuthRedirect(
          auth: const AuthState(isInitialized: true),
          onboardingCompleted: false,
          legalTermsAccepted: false,
          path: '/legal/privacy',
        ),
        isNull,
      );
    });

    test('guest without terms acceptance is sent to welcome from pokedex', () {
      expect(
        resolveAuthRedirect(
          auth: const AuthState(isInitialized: true),
          onboardingCompleted: onboardingDone,
          legalTermsAccepted: false,
          path: '/pokedex',
        ),
        '/welcome',
      );
    });

    test('guest without terms can stay on welcome', () {
      expect(
        resolveAuthRedirect(
          auth: const AuthState(isInitialized: true),
          onboardingCompleted: onboardingDone,
          legalTermsAccepted: false,
          path: '/welcome',
        ),
        isNull,
      );
    });
  });
}
