import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/network/offline_http_overrides.dart';

class _FakeConnectivityService extends ConnectivityService {
  _FakeConnectivityService(this._isOnline);

  bool _isOnline;

  @override
  bool get isOnline => _isOnline;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  tearDown(() {
    HttpOverrides.global = null;
  });

  test('HttpOverrides blocks socket connections when offline', () async {
    HttpOverrides.global = OfflineHttpOverrides(
      _FakeConnectivityService(false),
    );
    final client = HttpClient();

    Object? caught;
    try {
      final request = await client.getUrl(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/1'),
      );
      await request.close();
    } catch (error) {
      caught = error;
    }

    expect(caught, isA<SocketException>());
    expect(
      (caught! as SocketException).message,
      OfflineHttpOverrides.offlineMessage,
    );
    client.close();
  });

  test(
    'HttpOverrides does not block with offline message when online',
    () async {
      HttpOverrides.global = OfflineHttpOverrides(
        _FakeConnectivityService(true),
      );
      final client = HttpClient();

      try {
        final request = await client.getUrl(Uri.parse('https://127.0.0.1:1'));
        await request.close();
        fail('Expected connection failure');
      } on SocketException catch (error) {
        expect(error.message, isNot(OfflineHttpOverrides.offlineMessage));
      } finally {
        client.close();
      }
    },
  );
}
