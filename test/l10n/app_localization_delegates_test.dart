import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/l10n_test_helper.dart';

void main() {
  testWidgets(
    'Flutter text selection toolbar resolves Material localizations',
    (tester) async {
      late flutter_material.BuildContext captured;

      await pumpLocalizedApp(
        tester,
        child: flutter_material.Builder(
          builder: (context) {
            captured = context;
            return const flutter_material.SizedBox.shrink();
          },
        ),
      );

      final label =
          flutter_material.AdaptiveTextSelectionToolbar.getButtonLabel(
            captured,
            flutter_material.ContextMenuButtonItem(
              onPressed: () {},
              type: flutter_material.ContextMenuButtonType.copy,
            ),
          );

      expect(label, 'Copiar');
    },
  );
}
