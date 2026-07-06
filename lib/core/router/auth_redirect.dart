import 'package:pokedex_app/features/auth/domain/auth_state.dart';

bool isPublicAuthRoute(String path) {
  return path == '/onboarding' ||
      path == '/welcome' ||
      path.startsWith('/login') ||
      path.startsWith('/register') ||
      path == '/forgot-password';
}

bool isPublicLegalRoute(String path) {
  return path == '/legal/terms' || path == '/legal/privacy';
}

bool isGuestShellRoute(String path) {
  return path == '/pokedex' ||
      path.startsWith('/regions') ||
      path == '/favorites' ||
      path == '/profile' ||
      path.startsWith('/pokemon/');
}

bool isGuestAccessibleProfileRoute(String path) {
  return path == '/profile/terms' ||
      path == '/profile/privacy' ||
      path == '/profile/help' ||
      path == '/profile/about';
}

bool isLegalAcceptanceExemptRoute(String path) {
  return isPublicAuthRoute(path) || isPublicLegalRoute(path);
}

/// Resolves auth-aware redirects for the app router.
String? resolveAuthRedirect({
  required AuthState auth,
  required bool onboardingCompleted,
  required bool legalTermsAccepted,
  required String path,
}) {
  if (!onboardingCompleted) {
    if (path == '/onboarding' || isPublicLegalRoute(path)) {
      return null;
    }
    return '/onboarding';
  }

  if (!legalTermsAccepted) {
    if (isLegalAcceptanceExemptRoute(path)) {
      return null;
    }
    return '/welcome';
  }

  if (path == '/onboarding') {
    return auth.isAuthenticated ? '/pokedex' : '/welcome';
  }

  if (!auth.isAuthenticated) {
    if (path == '/login/success' || path == '/register/success') {
      return '/welcome';
    }
    if (isPublicAuthRoute(path) ||
        isPublicLegalRoute(path) ||
        isGuestShellRoute(path) ||
        isGuestAccessibleProfileRoute(path)) {
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
