import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/router/auth_redirect.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';

void main() {
  const onboardingDone = true;

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
            path: '/register/verify-email',
          ),
          '/register/success',
        );
      },
    );

    test(
      'verified user on register email route goes to register success',
      () {
        expect(
          resolveAuthRedirect(
            auth: authenticated(),
            onboardingCompleted: onboardingDone,
            path: '/register/email',
          ),
          '/register/success',
        );
      },
    );

    test(
      'unverified user stays on verify-email route',
      () {
        expect(
          resolveAuthRedirect(
            auth: authenticated(emailVerified: false),
            onboardingCompleted: onboardingDone,
            path: '/register/verify-email',
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
            path: '/register/success',
          ),
          isNull,
        );
      },
    );
  });
}
