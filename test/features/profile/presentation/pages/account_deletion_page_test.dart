import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/profile/presentation/pages/account_deletion_page.dart';
import '../../../../helpers/l10n_test_helper.dart';

void main() {
  testWidgets('account deletion page shows deletion instructions', (
    tester,
  ) async {
    await pumpLocalizedApp(
      tester,
      child: DefaultAssetBundle(
        bundle: _TestAssetBundle({
          'assets/legal/account_deletion_pt_br.md':
              '# Exclusão de conta e dados - PokeData\n\n'
              'Envie um e-mail para pokedata.app@gmail.com.',
        }),
        child: const AccountDeletionPage(),
      ),
      overrides: [],
    );
    await tester.pumpAndSettle();

    expect(find.text('Exclusão de conta e dados'), findsOneWidget);
    expect(find.textContaining('PokeData'), findsOneWidget);
    expect(find.textContaining('pokedata.app@gmail.com'), findsOneWidget);
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
