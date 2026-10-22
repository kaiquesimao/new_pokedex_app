import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/whats_new/presentation/widgets/whats_new_sheet.dart';

import '../../../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('sheet shows the changelog and returns the tapped action', (
    tester,
  ) async {
    final actions = <WhatsNewSheetAction?>[];

    await pumpLocalizedApp(
      tester,
      child: Builder(
        builder: (context) {
          return TextButton(
            onPressed: () async {
              actions.add(
                await showWhatsNewSheet(
                  context,
                  versionName: '1.6.12',
                  changelog: 'Pokémon vistos recentemente ficam no topo.',
                ),
              );
            },
            child: const Text('open'),
          );
        },
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('O que há de novo'), findsOneWidget);
    expect(find.text('Versão 1.6.12'), findsOneWidget);
    expect(
      find.text('Pokémon vistos recentemente ficam no topo.'),
      findsOneWidget,
    );
    expect(find.text('Entendi'), findsOneWidget);
    expect(find.text('Jogar'), findsOneWidget);
    expect(find.text('Avaliar o app'), findsOneWidget);

    await tester.tap(find.text('Jogar'));
    await tester.pumpAndSettle();

    expect(actions.single, WhatsNewSheetAction.play);
    expect(find.text('O que há de novo'), findsNothing);
  });
}
