import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import '../../../../helpers/firebase_test_overrides.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:pokedex_app/features/profile/presentation/pages/profile_page.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';

void main() {
  testWidgets('profile shows account rows and logout when authenticated', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseUnavailableOverride,
          authProvider.overrideWith(
            (ref) => AuthNotifier(
              initial: const AuthState(
                isInitialized: true,
                isAuthenticated: true,
                email: 'ash@pokemon.com',
                displayName: 'Ash',
              ),
            ),
          ),
          profileSettingsProvider.overrideWith(
            (ref) => ProfileSettingsNotifier(const ProfileSettings()),
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );

    expect(find.text('Ash'), findsOneWidget);
    expect(find.text('ash@pokemon.com'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Sair'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Sair'), findsOneWidget);
    expect(find.text('Você entrou como Ash'), findsOneWidget);
  });
}
