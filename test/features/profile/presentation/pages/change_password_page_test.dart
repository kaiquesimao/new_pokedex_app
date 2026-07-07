import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/profile/presentation/pages/change_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/firebase_test_overrides.dart';
import '../../../../helpers/l10n_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('change password flow advances through steps', (tester) async {
    SharedPreferences.setMockInitialValues({
      'mock_auth_session': true,
      'mock_auth_email': 'ash@pokemon.com',
      'mock_auth_name': 'Ash',
      'mock_auth_password': 'senha123',
    });

    await pumpLocalizedApp(
      tester,
      child: const ChangePasswordPage(),
      overrides: [
        firebaseUnavailableOverride,
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(
            isInitialized: true,
            isAuthenticated: true,
            email: 'ash@pokemon.com',
            displayName: 'Ash',
          ),
        ),
      ],
    );

    expect(find.text('Qual é sua senha atual?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'senha123');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Crie uma nova senha'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nova123');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Confirme a nova senha'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nova123');
    await tester.tap(find.text('Salvar senha'));
    await tester.pumpAndSettle();

    expect(find.text('Senha alterada com sucesso!'), findsOneWidget);
  });

  testWidgets('change password page redirects social account', (tester) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (_, _) => const Scaffold(body: Text('Perfil')),
        ),
        GoRoute(
          path: '/profile/change-password',
          builder: (_, _) => const ChangePasswordPage(),
        ),
      ],
    );

    await pumpLocalizedApp(
      tester,
      child: Router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
      ),
      overrides: [
        firebaseUnavailableOverride,
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(
            isInitialized: true,
            isAuthenticated: true,
            canEditCredentials: false,
          ),
        ),
      ],
    );

    unawaited(router.push('/profile/change-password'));
    await tester.pumpAndSettle();

    expect(find.text('Qual é sua senha atual?'), findsNothing);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
