import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/support/support_prompt_dialog.dart';

import '../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('support prompt dialog shows title, body, and actions', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showSupportPromptDialog(context),
                child: const Text('open'),
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Obrigado por apoiar o PokeData'), findsOneWidget);
    expect(
      find.text('Se puder, um café ajuda a manter o app no ar e a melhorar ele.'),
      findsOneWidget,
    );
    expect(find.text('Doar no Ko-fi'), findsOneWidget);
    expect(find.text('Agora não'), findsOneWidget);

    await tester.tap(find.text('Agora não'));
    await tester.pumpAndSettle();
    expect(find.text('Obrigado por apoiar o PokeData'), findsNothing);
  });
}
