import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/profile/presentation/pages/terms_of_use_page.dart';
import '../../../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('terms page shows disclaimer and scrollable sections', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      child: DefaultAssetBundle(
        bundle: _TestAssetBundle({
          'assets/legal/terms_pt_br.md':
              '# Termos de Uso - PokeData\n\n'
              'O PokeData não é desenvolvido, endossado ou afiliado.',
        }),
        child: const TermsOfUsePage(),
      ),
      overrides: [],
    );
    await tester.pumpAndSettle();

    expect(find.text('Termos de uso'), findsOneWidget);
    expect(
      find.textContaining('não é desenvolvido, endossado ou afiliado'),
      findsOneWidget,
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}

class _TestAssetBundle extends CachingAssetBundle {
  _TestAssetBundle(this.files);

  final Map<String, String> files;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = files[key];
    if (value == null) {
      throw FlutterError('Asset not found in test bundle: $key');
    }
    return value;
  }

  @override
  Future<ByteData> load(String key) async {
    final value = files[key];
    if (value == null) {
      throw FlutterError('Asset not found in test bundle: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.view(bytes.buffer);
  }
}
