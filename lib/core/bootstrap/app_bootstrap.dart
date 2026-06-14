import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/pokemon/presentation/providers/pokemon_list_provider.dart';

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

  if (isOnline) {
    unawaited(repository.warmPokemonNameIndex());
  }

  unawaited(
    authInit.then((_) {
      final auth = container.read(authProvider);
      if (auth.isAuthenticated && isOnline) {
        container.read(appDatabaseProvider);
        unawaited(container.read(pokemonListProvider.notifier).loadInitial());
      }
    }),
  );

  await authInit;
}
