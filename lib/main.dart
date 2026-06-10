import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/app.dart';
import 'package:pokedex_app/core/constants/firebase_auth_config.dart';
import 'package:pokedex_app/core/firebase/firebase_bootstrap.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/core/providers/firebase_providers.dart';
import 'package:pokedex_app/core/providers/theme_provider.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrapResult = await bootstrapFirebase();
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
    );
    await firebaseAuthNotifier.initialize();
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        firebaseBootstrapProvider.overrideWithValue(bootstrapResult),
        if (firebaseAuthNotifier != null)
          authProvider.overrideWith((ref) => firebaseAuthNotifier!)
        else
          authProvider.overrideWith(
            (ref) => AuthNotifier(initial: initialAuth),
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
      child: const PokedexApp(),
    ),
  );
}
