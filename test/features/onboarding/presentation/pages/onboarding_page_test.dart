import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/l10n_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('skip jumps to the last onboarding slide', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await pumpLocalizedApp(
      tester,
      child: const OnboardingPage(),
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

    expect(find.text('Pular'), findsOneWidget);
    expect(find.text('Todos os Pokémon em um só Lugar'), findsOneWidget);

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    expect(find.text('Mantenha sua PokeData atualizada'), findsOneWidget);
    expect(find.text('Vamos começar!'), findsOneWidget);
    expect(find.text('Pular'), findsNothing);
  });

  testWidgets('continue reveals the search walkthrough slide', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await pumpLocalizedApp(
      tester,
      child: const OnboardingPage(),
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Busque por tipo e região'), findsOneWidget);
  });
}
