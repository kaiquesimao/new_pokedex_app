import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/profile/domain/entities/profile_settings.dart';
import 'package:pokedex_app/features/profile/presentation/pages/privacy_policy_page.dart';
import 'package:pokedex_app/features/profile/presentation/pages/profile_page.dart';
import 'package:pokedex_app/features/profile/presentation/pages/terms_of_use_page.dart';
import 'package:pokedex_app/features/profile/presentation/providers/profile_settings_provider.dart';

import '../../../../helpers/firebase_test_overrides.dart';

void main() {
  testWidgets('profile shows account rows and logout when authenticated', (
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
              email: 'ash@pokemon.com',
              displayName: 'Ash',
            ),
          ),
          profileSettingsProvider.overrideWithBuild(
            (ref, notifier) => const ProfileSettings(),
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

  testWidgets('profile shows guest CTAs when unauthenticated', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseUnavailableOverride,
          authProvider.overrideWithBuild(
            (ref, notifier) => const AuthState(isInitialized: true),
          ),
          profileSettingsProvider.overrideWithBuild(
            (ref, notifier) => const ProfileSettings(),
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.text('Sair'), findsNothing);
  });

  testWidgets('profile terms link navigates to terms page', (tester) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
        GoRoute(
          path: '/legal/terms',
          builder: (_, _) => const TermsOfUsePage(),
        ),
        GoRoute(
          path: '/legal/privacy',
          builder: (_, _) => const PrivacyPolicyPage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseUnavailableOverride,
          authProvider.overrideWithBuild(
            (ref, notifier) => const AuthState(isInitialized: true),
          ),
          profileSettingsProvider.overrideWithBuild(
            (ref, notifier) => const ProfileSettings(),
          ),
        ],
        child: DefaultAssetBundle(
          bundle: _TestAssetBundle({
            'assets/legal/terms_pt_br.md':
                '# Termos de Uso - PokeData\n\n'
                'não é desenvolvido, endossado ou afiliado',
          }),
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Termos de uso'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Termos de uso'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('não é desenvolvido, endossado ou afiliado'),
      findsOneWidget,
    );
  });

  testWidgets('profile privacy link navigates to privacy page', (tester) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
        GoRoute(
          path: '/legal/privacy',
          builder: (_, _) => const PrivacyPolicyPage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseUnavailableOverride,
          authProvider.overrideWithBuild(
            (ref, notifier) => const AuthState(isInitialized: true),
          ),
          profileSettingsProvider.overrideWithBuild(
            (ref, notifier) => const ProfileSettings(),
          ),
        ],
        child: DefaultAssetBundle(
          bundle: _TestAssetBundle({
            'assets/legal/privacy_pt_br.md':
                '# Política de Privacidade - PokeData\n\n'
                'texto teste',
          }),
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Política de privacidade'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Política de privacidade'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Política de Privacidade - PokeData'),
      findsOneWidget,
    );
  });
}

class _TestAssetBundle extends CachingAssetBundle {
  _TestAssetBundle(this.files);

  final Map<String, String> files;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = files[key];
    if (value == null) {
      throw FlutterError('Asset not found in test bundle: $key');
    }
    return value;
  }

  @override
  Future<ByteData> load(String key) async {
    final value = files[key];
    if (value == null) {
      throw FlutterError('Asset not found in test bundle: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.view(bytes.buffer);
  }
}
