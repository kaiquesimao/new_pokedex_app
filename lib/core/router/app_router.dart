import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/router/app_initial_location_provider.dart';
import 'package:pokedex_app/core/router/auth_redirect.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/pages/auth_welcome_page.dart';
import 'package:pokedex_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:pokedex_app/features/auth/presentation/pages/login_email_page.dart';
import 'package:pokedex_app/features/auth/presentation/pages/login_page.dart';
import 'package:pokedex_app/features/auth/presentation/pages/login_success_page.dart';
import 'package:pokedex_app/features/auth/presentation/pages/register_email_page.dart';
import 'package:pokedex_app/features/auth/presentation/pages/register_page.dart';
import 'package:pokedex_app/features/auth/presentation/pages/register_success_page.dart';
import 'package:pokedex_app/features/auth/presentation/pages/verify_email_page.dart';
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
import 'package:pokedex_app/features/shell/presentation/widgets/animated_branch_container.dart';
import 'package:pokedex_app/features/shell/presentation/widgets/shell_tab_scope.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Notifies GoRouter when auth-related state changes so redirect re-runs.
class GoRouterRefreshNotifier extends ChangeNotifier {
  void notifyRouter() => notifyListeners();
}

final goRouterRefreshNotifierProvider = Provider<GoRouterRefreshNotifier>((
  ref,
) {
  final notifier = GoRouterRefreshNotifier();
  ref
    ..listen<AuthState>(authProvider, (_, _) => notifier.notifyRouter())
    ..listen<bool>(onboardingProvider, (_, _) => notifier.notifyRouter())
    ..onDispose(notifier.dispose);
  return notifier;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(goRouterRefreshNotifierProvider);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,

    initialLocation: ref.watch(appInitialLocationProvider),

    refreshListenable: refreshListenable,

    redirect: (context, state) {
      return resolveAuthRedirect(
        auth: ref.read(authProvider),
        onboardingCompleted: ref.read(onboardingProvider),
        path: state.uri.path,
      );
    },

    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),

      GoRoute(path: '/welcome', builder: (_, _) => const AuthWelcomePage()),

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

      StatefulShellRoute(
        builder: (_, _, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (_, navigationShell, children) {
          return AnimatedBranchContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
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

  ref.onDispose(router.dispose);

  return router;
});
