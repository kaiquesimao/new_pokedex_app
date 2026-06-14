import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pokedex_app/app.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:pokedex_app/core/router/app_initial_location_provider.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import '../test/helpers/firebase_test_overrides.dart';
import 'package:pokedex_app/core/providers/theme_provider.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User journey: cold start (onboarding já concluído) → lista Pokédex → tap no
/// primeiro card, se a lista carregar.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('app flow smoke', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({onboardingCompletedKey: true});
      prefs = await SharedPreferences.getInstance();
    });

    Widget buildTestApp() {
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          firebaseUnavailableOverride,
          authProvider.overrideWith(
            (ref) => AuthNotifier(
              initial: const AuthState(
                isInitialized: true,
                isAuthenticated: true,
                email: 'test@pokemon.com',
                displayName: 'Test',
              ),
            ),
          ),
          onboardingProvider.overrideWith((ref) => OnboardingNotifier(true)),
          themeModeProvider.overrideWith(
            (ref) => ThemeModeNotifier(ThemeMode.light),
          ),
          profileAvatarProvider.overrideWith(
            (ref) => ProfileNotifier(TrainerAvatars.defaultSlug),
          ),
          profileSettingsProvider.overrideWith(
            (ref) => ProfileSettingsNotifier(const ProfileSettings()),
          ),
          appInitialLocationHolderProvider.overrideWithValue(
            AppInitialLocation('/pokedex'),
          ),
        ],
        child: const PokedexApp(),
      );
    }

    testWidgets('opens pokedex list on launch', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 8));

      expect(find.widgetWithText(AppBar, 'Pokédex'), findsOneWidget);
    });

    testWidgets('pokedex list card opens detail when data is available', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.widgetWithText(AppBar, 'Pokédex'), findsOneWidget);

      final cards = find.byType(PokemonListRowCard);
      if (cards.evaluate().isEmpty) {
        // API offline or still loading — list smoke already verified above.
        return;
      }

      await tester.tap(cards.first);
      await tester.pumpAndSettle(const Duration(seconds: 15));

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsWidgets);
    });
  });
}
