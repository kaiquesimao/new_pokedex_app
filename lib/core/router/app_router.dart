import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:pokedex_app/features/auth/presentation/pages/forgot_password_page.dart';

import 'package:pokedex_app/features/auth/presentation/pages/login_email_page.dart';

import 'package:pokedex_app/features/auth/presentation/pages/login_page.dart';

import 'package:pokedex_app/features/auth/presentation/pages/login_success_page.dart';

import 'package:pokedex_app/features/auth/presentation/pages/register_email_page.dart';

import 'package:pokedex_app/features/auth/presentation/pages/register_page.dart';

import 'package:pokedex_app/features/auth/presentation/pages/register_success_page.dart';

import 'package:pokedex_app/features/auth/presentation/pages/splash_page.dart';

import 'package:pokedex_app/features/auth/presentation/pages/verify_email_page.dart';

import 'package:pokedex_app/features/auth/domain/auth_state.dart';

import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';

import 'package:pokedex_app/features/favorites/presentation/pages/favorites_page.dart';

import 'package:pokedex_app/features/onboarding/presentation/pages/onboarding_page.dart';

import 'package:pokedex_app/features/onboarding/presentation/providers/onboarding_provider.dart';

import 'package:pokedex_app/features/pokemon/presentation/pages/pokemon_detail_page.dart';

import 'package:pokedex_app/features/pokemon/presentation/pages/pokemon_list_page.dart';

import 'package:pokedex_app/features/profile/presentation/pages/change_password_page.dart';

import 'package:pokedex_app/features/profile/presentation/pages/profile_page.dart';

import 'package:pokedex_app/features/regions/presentation/pages/regional_pokedex_page.dart';

import 'package:pokedex_app/features/regions/presentation/pages/regions_page.dart';

import 'package:pokedex_app/features/shell/presentation/pages/main_shell_page.dart';

import 'package:pokedex_app/features/shell/presentation/widgets/shell_tab_scope.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

bool _isPublicAuthRoute(String path) {
  return path == '/onboarding' ||
      path.startsWith('/login') ||
      path.startsWith('/register') ||
      path == '/forgot-password';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,

    initialLocation: '/splash',

    redirect: (context, state) {
      final auth = ref.read(authProvider);

      final onboardingCompleted = ref.read(onboardingProvider);

      final path = state.uri.path;

      if (!auth.isInitialized) {
        return path == '/splash' ? null : '/splash';
      }

      if (path == '/splash') return null;

      if (!onboardingCompleted) {
        return path == '/onboarding' ? null : '/onboarding';
      }

      if (path == '/onboarding') {
        return auth.isAuthenticated ? '/pokedex' : '/login';
      }

      if (!auth.isAuthenticated) {
        if (path == '/login/success' || path == '/register/success') {
          return '/login';
        }
        return _isPublicAuthRoute(path) ? null : '/login';
      }

      if (path == '/login/success' || path == '/register/success') {
        return null;
      }

      if (_isPublicAuthRoute(path)) {
        return switch (path) {
          '/login' || '/login/email' => '/login/success',
          '/register' => '/register/success',
          _ => '/pokedex',
        };
      }

      return null;
    },

    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),

      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),

      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),

      GoRoute(path: '/login/email', builder: (_, _) => const LoginEmailPage()),

      GoRoute(
        path: '/login/success',

        builder: (_, _) => const LoginSuccessPage(),
      ),

      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),

      GoRoute(
        path: '/register/email',

        builder: (_, _) => const RegisterEmailPage(),
      ),

      GoRoute(
        path: '/register/verify-email',

        builder: (_, _) => const VerifyEmailPage(),
      ),

      GoRoute(
        path: '/register/success',

        builder: (_, _) => const RegisterSuccessPage(),
      ),

      GoRoute(
        path: '/forgot-password',

        builder: (_, _) => const ForgotPasswordPage(),
      ),

      GoRoute(
        path: '/profile/change-password',

        parentNavigatorKey: _rootNavigatorKey,

        builder: (_, _) => const ChangePasswordPage(),
      ),

      GoRoute(
        path: '/pokemon/:id',

        parentNavigatorKey: _rootNavigatorKey,

        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);

          return CustomTransitionPage<void>(
            key: state.pageKey,

            transitionDuration: const Duration(milliseconds: 350),

            reverseTransitionDuration: const Duration(milliseconds: 300),

            child: PokemonDetailPage(pokemonId: id),

            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,

                    curve: Curves.easeOutCubic,
                  );

                  return FadeTransition(opacity: curved, child: child);
                },
          );
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },

        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pokedex',

                builder: (_, _) => const PokemonListPage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/regions',

                builder: (_, _) =>
                    const LazyShellTab(tabIndex: 1, child: RegionsPage()),

                routes: [
                  GoRoute(
                    path: ':name',

                    parentNavigatorKey: _rootNavigatorKey,

                    builder: (_, state) {
                      final name = state.pathParameters['name']!;

                      return RegionalPokedexPage(regionName: name);
                    },
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',

                builder: (_, _) =>
                    const LazyShellTab(tabIndex: 2, child: FavoritesPage()),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',

                builder: (_, _) =>
                    const LazyShellTab(tabIndex: 3, child: ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.listen<AuthState>(authProvider, (_, _) => router.refresh());

  ref.listen<bool>(onboardingProvider, (_, _) => router.refresh());

  ref.onDispose(router.dispose);

  return router;
});
