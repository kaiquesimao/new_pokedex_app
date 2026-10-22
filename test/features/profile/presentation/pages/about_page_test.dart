import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pokedex_app/core/providers/package_info_provider.dart';
import 'package:pokedex_app/features/profile/presentation/pages/about_page.dart';

import '../../../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('about page shows version, credits and disclaimer', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      child: const AboutPage(),
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
    );
    await tester.pumpAndSettle();

    expect(find.text('Sobre'), findsOneWidget);
    expect(find.text('PokeData'), findsOneWidget);
    expect(find.text('Versão 2.0.0 (42)'), findsOneWidget);
    expect(find.text('PokéAPI'), findsOneWidget);
    expect(find.text('Flutter'), findsNothing);
    expect(find.text('Firebase'), findsNothing);
    expect(find.text('Criado por'), findsOneWidget);
    expect(find.text('Kaique Simão'), findsOneWidget);
    expect(find.text('Agradecimentos'), findsOneWidget);
    expect(find.text('Junior Saraiva'), findsOneWidget);
    expect(find.text('Perfil no LinkedIn'), findsNWidgets(2));
    expect(find.text('Ver o design original'), findsOneWidget);
    expect(
      find.textContaining('Agradecemos pelos dados de Pokémon'),
      findsOneWidget,
    );
    expect(find.text('Apoiar o projeto'), findsOneWidget);
    expect(find.text('Doar no Ko-fi'), findsOneWidget);
    expect(
      find.textContaining('sem anúncios e nada fica travado'),
      findsOneWidget,
    );
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
