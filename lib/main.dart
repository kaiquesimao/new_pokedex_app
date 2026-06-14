import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/app.dart';
import 'package:pokedex_app/core/bootstrap/app_bootstrap.dart';
import 'package:pokedex_app/core/constants/firebase_auth_config.dart';
import 'package:pokedex_app/core/firebase/firebase_bootstrap.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/network/network_access_coordinator.dart';
import 'package:pokedex_app/core/network/offline_http_overrides.dart';
import 'package:pokedex_app/core/providers/connectivity_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/core/providers/theme_provider.dart';
import 'package:pokedex_app/core/router/app_initial_location_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

  if (!kIsWeb) {
    HttpOverrides.global = OfflineHttpOverrides(connectivityService);
  }

  final bootstrapResult = await bootstrapFirebase();

  final networkCoordinator = NetworkAccessCoordinator(
    connectivity: connectivityService,
    firebaseAvailable: bootstrapResult.isAvailable,
  );
  await networkCoordinator.start();
  final prefs = await SharedPreferences.getInstance();
  final initialThemeMode = readStoredThemeMode(prefs);
  final initialAvatarSlug = readStoredAvatarSlug(prefs);
  final initialAuth = readStoredAuthState(prefs);
  final initialOnboardingCompleted = readOnboardingCompleted(prefs);
  final initialProfileSettings = readStoredProfileSettings(prefs);

  AuthNotifier? firebaseAuthNotifier;
  if (bootstrapResult.isAvailable) {
    firebaseAuthNotifier = AuthNotifier(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: FirebaseAuthConfig.createGoogleSignIn(),
      connectivity: connectivityService,
    );
    await firebaseAuthNotifier.initialize();
  }

  final initialLocationHolder = AppInitialLocation('/welcome');

  final container = ProviderContainer(
    overrides: [
      connectivityServiceProvider.overrideWithValue(connectivityService),
      sharedPreferencesProvider.overrideWithValue(prefs),
      firebaseBootstrapProvider.overrideWithValue(bootstrapResult),
      appInitialLocationHolderProvider.overrideWithValue(initialLocationHolder),
      if (firebaseAuthNotifier != null)
        authProvider.overrideWith((ref) => firebaseAuthNotifier!)
      else
        authProvider.overrideWith(
          (ref) => AuthNotifier(
            initial: initialAuth,
            connectivity: connectivityService,
          ),
        ),
      onboardingProvider.overrideWith(
        (ref) => OnboardingNotifier(initialOnboardingCompleted),
      ),
      themeModeProvider.overrideWith(
        (ref) => ThemeModeNotifier(initialThemeMode),
      ),
      profileAvatarProvider.overrideWith(
        (ref) => ProfileNotifier(initialAvatarSlug),
      ),
      profileSettingsProvider.overrideWith(
        (ref) => ProfileSettingsNotifier(initialProfileSettings),
      ),
    ],
  );

  await runAppBootstrap(container);

  initialLocationHolder.value = resolveInitialLocation(
    onboardingCompleted: container.read(onboardingProvider),
    auth: container.read(authProvider),
  );

  FlutterNativeSplash.remove();

  runApp(
    UncontrolledProviderScope(container: container, child: const PokedexApp()),
  );
}
