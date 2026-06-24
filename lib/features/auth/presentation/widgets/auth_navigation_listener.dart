import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/router/app_router.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';

/// Navigates to [postLoginRoute] when the user becomes authenticated on an auth screen.
void listenPostLoginNavigation(
  WidgetRef ref, {
  String postLoginRoute = '/login/success',
}) {
  ref.listen<AuthState>(authProvider, (previous, next) {
    final wasAuthenticated = previous?.isAuthenticated ?? false;
    if (wasAuthenticated || !next.isAuthenticated) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(goRouterProvider).go(postLoginRoute);
    });
  });
}
