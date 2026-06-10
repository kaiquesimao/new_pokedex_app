import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/network/dio_client.dart';
import 'package:pokedex_app/core/network/offline_http_overrides.dart';

class _OnlineConnectivity extends ConnectivityService {
  @override
  bool get isOnline => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  tearDown(() {
    HttpOverrides.global = null;
  });

  test(
    'Dio reaches PokeAPI through OfflineHttpOverrides while online',
    () async {
      HttpOverrides.global = OfflineHttpOverrides(_OnlineConnectivity());
      final dio = createDio(connectivity: _OnlineConnectivity());

      final response = await dio.get<Map<String, dynamic>>(
        '/pokemon',
        queryParameters: {'offset': 0, 'limit': 20},
      );

      expect(response.statusCode, 200);
      expect(response.data?['results'], isA<List<dynamic>>());
      expect((response.data?['results'] as List).isNotEmpty, isTrue);
    },
  );
}
