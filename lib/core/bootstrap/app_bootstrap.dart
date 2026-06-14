import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';

String resolveInitialLocation({
  required bool onboardingCompleted,
  required AuthState auth,
}) {
  if (!onboardingCompleted) return '/onboarding';
  if (auth.isAuthenticated) return '/pokedex';
  return '/welcome';
}

/// Runs blocking cold-start work while the native splash is visible.
Future<void> runAppBootstrap(ProviderContainer container) async {
  final authInit = container.read(authProvider.notifier).initialize();
  final repository = container.read(pokemonRepositoryProvider);
  final isOnline = container.read(connectivityServiceProvider).isOnline;

  // Warm the local DB and name index during splash; list loading stays on the page
  // so state updates always happen after the widget tree is listening.
  container.read(appDatabaseProvider);

  if (isOnline) {
    unawaited(repository.warmPokemonNameIndex());
  }

  await authInit;
}
