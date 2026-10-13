import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/providers/core_providers.dart';
import 'package:pokedex_app/features/home_tutorial/domain/home_tutorial_step.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/providers/home_tutorial_provider.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/widgets/home_tutorial_overlay.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/widgets/home_tutorial_target.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/l10n_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('skip completes tutorial and hides overlay', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    late ProviderContainer container;
    await pumpLocalizedApp(
      tester,
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: Consumer(
        builder: (context, ref, _) {
          container = ProviderScope.containerOf(context);
          final active = ref.watch(homeTutorialProvider.select((s) => s.isActive));
          return Stack(
            children: [
              const Scaffold(
                body: HomeTutorialTarget(
                  step: HomeTutorialStepId.search,
                  child: SizedBox(width: 200, height: 48),
                ),
              ),
              if (active) const HomeTutorialOverlay(),
            ],
          );
        },
      ),
    );

    container.read(homeTutorialProvider.notifier).tryAutoStart();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Buscar Pokémon'), findsOneWidget);
    expect(find.text('Pular'), findsOneWidget);

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    expect(find.text('Buscar Pokémon'), findsNothing);
    expect(container.read(homeTutorialProvider).completed, isTrue);
  });

  testWidgets('next advances to filters step', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    late ProviderContainer container;
    await pumpLocalizedApp(
      tester,
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: Consumer(
        builder: (context, ref, _) {
          container = ProviderScope.containerOf(context);
          final active = ref.watch(homeTutorialProvider.select((s) => s.isActive));
          return Stack(
            children: [
              const Scaffold(
                body: Column(
                  children: [
                    HomeTutorialTarget(
                      step: HomeTutorialStepId.search,
                      child: SizedBox(width: 200, height: 48),
                    ),
                    HomeTutorialTarget(
                      step: HomeTutorialStepId.filters,
                      child: SizedBox(width: 200, height: 40),
                    ),
                  ],
                ),
              ),
              if (active) const HomeTutorialOverlay(),
            ],
          );
        },
      ),
    );

    container.read(homeTutorialProvider.notifier).tryAutoStart();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();

    expect(find.text('Filtrar e ordenar'), findsOneWidget);
    expect(container.read(homeTutorialProvider).stepIndex, 1);
  });
}
