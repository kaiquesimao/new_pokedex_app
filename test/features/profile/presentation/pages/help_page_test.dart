import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/profile/presentation/pages/help_page.dart';

void main() {
  testWidgets('help page shows faq items and support email', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HelpPage()),
    );
    await tester.pumpAndSettle();

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
