import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:pokedex_app/shared/widgets/empty_state_illustration.dart';

import '../../../../helpers/firebase_test_overrides.dart';
import '../../../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('favorites page shows login CTA for guests', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: const FavoritesPage(),
      overrides: [
        firebaseUnavailableOverride,
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(isInitialized: true),
        ),
      ],
    );

    expect(
      find.text('Você precisa entrar em uma conta para fazer isso.'),
      findsOneWidget,
    );
    expect(find.text('Entre ou Cadastre-se'), findsOneWidget);
    expect(find.text('Você não favoritou nenhum Pokémon :('), findsNothing);
  });

  testWidgets('guest favorites empty state fits phone viewport without scroll', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpLocalizedApp(
      tester,
      child: const FavoritesPage(),
      overrides: [
        firebaseUnavailableOverride,
        authProvider.overrideWithBuild(
          (ref, notifier) => const AuthState(isInitialized: true),
        ),
      ],
    );

    expect(find.byType(EmptyStateIllustration), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(EmptyStateIllustration),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );

    final page = tester.getRect(find.byType(FavoritesPage));
    final cta = tester.getRect(find.text('Entre ou Cadastre-se'));
    expect(cta.bottom, lessThanOrEqualTo(page.bottom + 0.5));
    expect(cta.top, greaterThanOrEqualTo(page.top - 0.5));
  });
}
