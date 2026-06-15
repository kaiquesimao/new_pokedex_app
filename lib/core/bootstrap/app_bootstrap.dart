import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/firebase/firebase_bootstrap.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/network/network_access_coordinator.dart';
import 'package:pokedex_app/core/network/offline_http_overrides.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/core/router/app_initial_location_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String resolveInitialLocation({
  required bool onboardingCompleted,
  required bool isAuthenticated,
}) {
  if (!onboardingCompleted) return '/onboarding';
  if (isAuthenticated) return '/pokedex';
  return '/welcome';
}

class ColdStartResult {
  const ColdStartResult({
    required this.container,
    required this.initialLocationHolder,
    required this.networkCoordinator,
  });

  final ProviderContainer container;
  final AppInitialLocation initialLocationHolder;
  final NetworkAccessCoordinator networkCoordinator;
}

/// Runs the full cold-start pipeline with parallel waves where safe.
Future<ColdStartResult> runColdStart() async {
  final connectivityService = ConnectivityService();

  // Wave 1: independent I/O
  final results = await Future.wait([
    connectivityService.initialize(),
    bootstrapFirebase(),
    SharedPreferences.getInstance(),
  ]);

  final bootstrapResult = results[1] as FirebaseBootstrapResult;
  final prefs = results[2] as SharedPreferences;

  if (!kIsWeb) {
    HttpOverrides.global = OfflineHttpOverrides(connectivityService);
  }

  final networkCoordinator = NetworkAccessCoordinator(
    connectivity: connectivityService,
    firebaseAvailable: bootstrapResult.isAvailable,
  );

  final initialLocationHolder = AppInitialLocation('/welcome');

  final container = ProviderContainer(
    overrides: [
      connectivityServiceProvider.overrideWithValue(connectivityService),
      sharedPreferencesProvider.overrideWithValue(prefs),
      firebaseBootstrapProvider.overrideWithValue(bootstrapResult),
      appInitialLocationHolderProvider.overrideWithValue(initialLocationHolder),
    ],
  );

  // Wave 3: depends on Firebase + connectivity
  await Future.wait<void>([
    networkCoordinator.start(),
    container.read(authProvider.notifier).initialize(),
  ]);

  await _warmSplashResources(container);

  initialLocationHolder.value = resolveInitialLocation(
    onboardingCompleted: container.read(onboardingProvider),
    isAuthenticated: container.read(authProvider).isAuthenticated,
  );

  return ColdStartResult(
    container: container,
    initialLocationHolder: initialLocationHolder,
    networkCoordinator: networkCoordinator,
  );
}

/// Warms local resources during the native splash.
Future<void> _warmSplashResources(ProviderContainer container) async {
  final repository = container.read(pokemonRepositoryProvider);
  final isOnline = container.read(connectivityServiceProvider).isOnline;

  container.read(appDatabaseProvider);

  if (isOnline) {
    unawaited(repository.warmPokemonNameIndex());
  }
}
