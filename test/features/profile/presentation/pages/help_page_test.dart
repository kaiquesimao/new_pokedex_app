import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/profile/presentation/pages/help_page.dart';

import '../../../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('help page shows faq items and support email', (tester) async {
    await pumpLocalizedApp(tester, child: const HelpPage());

    expect(find.text('Ajuda'), findsOneWidget);
    expect(find.text('Perguntas frequentes'), findsOneWidget);
    expect(find.text('Suporte'), findsOneWidget);
    expect(find.text(HelpPage.supportEmail), findsOneWidget);
    expect(find.text('Como explorar sem criar conta?'), findsOneWidget);
    expect(find.text('Como favoritar Pokémon?'), findsOneWidget);
    expect(find.text('Como filtrar a lista de Pokémon?'), findsOneWidget);
    expect(find.text('Como alterar o idioma?'), findsOneWidget);
    expect(
      find.text('O que são mega evoluções e outras formas?'),
      findsOneWidget,
    );
    expect(find.text('O app funciona offline?'), findsOneWidget);
  });
}
