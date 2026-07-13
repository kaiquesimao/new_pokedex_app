import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/shared/widgets/detail_surface_card.dart';

import '../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('DetailSurfaceCard uses surface fill and child', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: const Scaffold(
        body: DetailSurfaceCard(
          child: Text('surface content'),
        ),
      ),
    );

    expect(find.text('surface content'), findsOneWidget);

    final theme = Theme.of(tester.element(find.byType(DetailSurfaceCard)));
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(DetailSurfaceCard),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, theme.colorScheme.surface);
    expect(decoration.borderRadius, BorderRadius.circular(16));
    expect(decoration.boxShadow, isNull);
  });

  testWidgets('DetailSurfaceCard light border matches token', (tester) async {
    await pumpLocalizedApp(
      tester,
      child: Theme(
        data: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        child: const Scaffold(
          body: DetailSurfaceCard(child: SizedBox.shrink()),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(DetailSurfaceCard),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    expect(
      border.top.color,
      AppColorsLight.textSecondary.withValues(alpha: 0.25),
    );
  });
}
