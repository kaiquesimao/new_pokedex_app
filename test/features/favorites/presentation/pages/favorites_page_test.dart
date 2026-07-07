import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/auth/domain/auth_state.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/features/favorites/presentation/pages/favorites_page.dart';

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
}
