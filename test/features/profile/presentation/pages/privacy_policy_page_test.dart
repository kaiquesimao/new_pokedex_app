import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/features/profile/presentation/pages/privacy_policy_page.dart';

void main() {
  testWidgets('privacy page shows policy content', (tester) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _TestAssetBundle({
          'assets/legal/privacy_pt_br.md':
              '# Política de Privacidade - PokeData\n\n'
              'Texto de exemplo da política.',
        }),
        child: const MaterialApp(home: PrivacyPolicyPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Política de privacidade'), findsOneWidget);
    expect(
      find.textContaining('Política de Privacidade - PokeData'),
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
