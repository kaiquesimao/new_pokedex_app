import 'package:pokedex_app/features/auth/domain/auth_state.dart';

bool isPublicAuthRoute(String path) {
  return path == '/onboarding' ||
      path == '/welcome' ||
      path.startsWith('/login') ||
      path.startsWith('/register') ||
      path == '/forgot-password';
}

bool isGuestShellRoute(String path) {
  return path == '/pokedex' ||
      path.startsWith('/regions') ||
      path == '/favorites' ||
      path == '/profile' ||
      path.startsWith('/pokemon/');
}

/// Resolves auth-aware redirects for the app router.
String? resolveAuthRedirect({
  required AuthState auth,
  required bool onboardingCompleted,
  required String path,
}) {
  if (!onboardingCompleted) {
    return path == '/onboarding' ? null : '/onboarding';
  }

  if (path == '/onboarding') {
    return auth.isAuthenticated ? '/pokedex' : '/welcome';
  }

  if (!auth.isAuthenticated) {
    if (path == '/login/success' || path == '/register/success') {
      return '/welcome';
    }
    if (isPublicAuthRoute(path) || isGuestShellRoute(path)) {
      return null;
    }
    return '/welcome';
  }

  if (auth.needsEmailVerification) {
    const pendingVerificationRoutes = {
      '/register/verify-email',
      '/register/email',
      '/register/success',
    };
    if (pendingVerificationRoutes.contains(path)) return null;
    return '/register/verify-email';
  }

  if (path == '/welcome') {
    return '/pokedex';
  }

  if (path == '/login/success' || path == '/register/success') {
    return null;
  }

  if (isPublicAuthRoute(path)) {
    return switch (path) {
      '/login' || '/login/email' => '/login/success',
      '/register' ||
      '/register/email' ||
      '/register/verify-email' => '/register/success',
      _ => '/pokedex',
    };
  }

  return null;
}
