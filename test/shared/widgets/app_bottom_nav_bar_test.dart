import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/locale/app_locale.dart';
import 'package:pokedex_app/shared/widgets/app_bottom_nav_bar.dart';

import '../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('nav labels PT shows Regiões', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: Scaffold(
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 1,
          onTap: (_) {},
        ),
      ),
    );

    expect(find.text('Regiões'), findsOneWidget);
  });

  testWidgets('nav labels EN shows Regions', (tester) async {
    await pumpLocalizedApp(
      tester,
      locale: AppLocale.en,
      child: Scaffold(
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 1,
          onTap: (_) {},
        ),
      ),
    );

    expect(find.text('Regions'), findsOneWidget);
  });
}
