import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/core/locale/legal_assets.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/profile/presentation/pages/help_page.dart';
import 'package:pokedex_app/features/profile/presentation/pages/privacy_policy_page.dart';
import 'package:pokedex_app/features/profile/presentation/pages/profile_page.dart';
import 'package:pokedex_app/features/profile/presentation/pages/terms_of_use_page.dart';
import 'package:pokedex_app/features/reviews/domain/app_review_service.dart';
import 'package:pokedex_app/features/reviews/presentation/providers/app_review_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fake_legal_documents_repository.dart';
import '../../../../helpers/firebase_test_overrides.dart';
import '../../../../helpers/l10n_test_helper.dart';
import '../../../../helpers/legal_test_overrides.dart';

void main() {
  testWidgets('profile shows account rows and logout when authenticated', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      child: const ProfilePage(),
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
        // profileSettingsProvider is set by pumpLocalizedApp
      ],
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
    expect(find.text('Excluir conta'), findsOneWidget);
    expect(find.text('Como funciona a exclusão de conta'), findsOneWidget);
    expect(find.text('Você entrou como Ash'), findsOneWidget);
  });

  testWidgets('profile hides password row for social account', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: const ProfilePage(),
      overrides: [
        firebaseUnavailableOverride,
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(
            isInitialized: true,
            isAuthenticated: true,
            email: 'ash@gmail.com',
            displayName: 'Ash',
            canEditCredentials: false,
          ),
        ),
        // profileSettingsProvider is set by pumpLocalizedApp
      ],
    );

    expect(find.text('Ash'), findsOneWidget);
    expect(find.text('ash@gmail.com'), findsOneWidget);
    expect(find.text('Senha'), findsNothing);
  });

  testWidgets('profile shows guest CTAs when unauthenticated', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: const ProfilePage(),
      overrides: [
        firebaseUnavailableOverride,
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(isInitialized: true),
        ),
        // profileSettingsProvider is set by pumpLocalizedApp
      ],
    );

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.text('Sair'), findsNothing);
    expect(find.text('Excluir conta'), findsNothing);
    expect(find.text('Como funciona a exclusão de conta'), findsNothing);
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

    await pumpLocalizedApp(
      tester,
      child: Router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
      ),
      overrides: [
        ...legalRepositoryOverrides(
          FakeLegalDocumentsRepository({
            legalDocumentId(LegalDocument.terms, AppLocale.pt):
                '# Termos de Uso - PokeData\n\n'
                'não é desenvolvido, endossado ou afiliado',
          }),
        ),
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(isInitialized: true),
        ),
        // profileSettingsProvider is set by pumpLocalizedApp
      ],
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

  testWidgets('profile help link navigates to help page', (tester) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
        GoRoute(path: '/profile/help', builder: (_, _) => const HelpPage()),
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
          (ref, notifier) => const AuthState(isInitialized: true),
        ),
        // profileSettingsProvider is set by pumpLocalizedApp
      ],
    );

    await tester.scrollUntilVisible(
      find.text('Ajuda'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajuda'));
    await tester.pumpAndSettle();

    expect(find.text('Perguntas frequentes'), findsOneWidget);
    expect(find.text('Suporte'), findsOneWidget);
    expect(find.text(HelpPage.supportEmail), findsOneWidget);
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

    await pumpLocalizedApp(
      tester,
      child: Router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
      ),
      overrides: [
        ...legalRepositoryOverrides(
          FakeLegalDocumentsRepository({
            legalDocumentId(LegalDocument.privacy, AppLocale.pt):
                '# Política de Privacidade - PokeData\n\n'
                'texto teste',
          }),
        ),
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(isInitialized: true),
        ),
        // profileSettingsProvider is set by pumpLocalizedApp
      ],
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

  testWidgets('profile shows rate app row and opens review flow', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final reviewService = _FakeReviewService();

    await pumpLocalizedApp(
      tester,
      child: const ProfilePage(),
      overrides: [
        firebaseUnavailableOverride,
        sharedPreferencesProvider.overrideWithValue(prefs),
        appReviewServiceProvider.overrideWithValue(reviewService),
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(isInitialized: true),
        ),
      ],
    );

    await tester.scrollUntilVisible(
      find.text('Avaliar o app'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Avaliar o app'));
    await tester.pumpAndSettle();

    expect(reviewService.settingsCalls, 1);
  });
}

class _FakeReviewService implements AppReviewService {
  int settingsCalls = 0;

  @override
  Future<bool> requestInAppReviewIfAvailable() async => false;

  @override
  Future<void> rateFromSettings() async {
    settingsCalls++;
  }
}
