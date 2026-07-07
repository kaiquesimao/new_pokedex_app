import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/profile/presentation/pages/edit_name_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/firebase_test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('edit name saves updated display name', (tester) async {
    SharedPreferences.setMockInitialValues({
      'mock_auth_session': true,
      'mock_auth_email': 'ash@pokemon.com',
      'mock_auth_name': 'Ash',
      'mock_auth_password': 'senha123',
    });
    final prefs = await SharedPreferences.getInstance();

    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (_, _) => const Scaffold(body: Text('Perfil')),
        ),
        GoRoute(
          path: '/profile/edit-name',
          builder: (_, _) => const EditNamePage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseUnavailableOverride,
          sharedPreferencesProvider.overrideWithValue(prefs),
          authProvider.overrideWithBuild(
            (ref, notifier) => readStoredAuthState(prefs),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(router.push('/profile/edit-name'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Misty');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('edit name shows validation error for empty name', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseUnavailableOverride,
          authProvider.overrideWithBuild(
            (ref, notifier) => const AuthState(
              isInitialized: true,
              isAuthenticated: true,
              displayName: 'Ash',
            ),
          ),
        ],
        child: const MaterialApp(home: EditNamePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe um nome'), findsOneWidget);
  });
}
