import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pokedex_app/core/providers/package_info_provider.dart';
import 'package:pokedex_app/features/profile/presentation/pages/about_page.dart';

void main() {
  testWidgets('about page shows version, credits and disclaimer', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: 'PokeData',
              packageName: 'com.example.pokedex',
              version: '2.0.0',
              buildNumber: '42',
            ),
          ),
        ],
        child: const MaterialApp(home: AboutPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sobre'), findsOneWidget);
    expect(find.text('PokeData'), findsOneWidget);
    expect(find.text('Versão 2.0.0 (42)'), findsOneWidget);
    expect(find.text('PokéAPI'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Firebase'), findsOneWidget);
    expect(find.text('Desenvolvido por'), findsOneWidget);
    expect(find.text('Kaique Simão'), findsOneWidget);
    expect(find.text('Agradecimentos'), findsOneWidget);
    expect(find.text('Junior Saraiva'), findsOneWidget);
    expect(find.text('Perfil no LinkedIn'), findsNWidgets(2));
    expect(find.text('Projeto no Figma'), findsOneWidget);
    expect(
      find.textContaining('Não é desenvolvido, endossado ou afiliado'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Pokémon © Nintendo / Creatures Inc. / GAME FREAK'),
      findsOneWidget,
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
