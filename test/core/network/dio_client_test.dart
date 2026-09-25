import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/network/dio_client.dart';
import 'package:pokedex_app/core/network/web_safe_headers_interceptor.dart';

void main() {
  group('pokeApiRequestHeaders', () {
    test('uses User-Agent on native', () {
      final headers = pokeApiRequestHeaders(
        appVersion: '1.0.0',
        isWeb: false,
      );

      expect(headers['User-Agent'], pokeApiClientId('1.0.0'));
      expect(headers.containsKey('X-PokeData-Client'), isFalse);
    });

    test('uses X-PokeData-Client on web', () {
      final headers = pokeApiRequestHeaders(
        appVersion: '2.0.0',
        isWeb: true,
      );

      expect(headers['X-PokeData-Client'], pokeApiClientId('2.0.0'));
      expect(headers.containsKey('User-Agent'), isFalse);
    });
  });

  group('stripForbiddenWebHeaders', () {
    test('removes forbidden headers', () {
      final headers = <String, dynamic>{
        'User-Agent': 'blocked',
        'Accept': 'application/json',
      };

      final stripped = stripForbiddenWebHeaders(headers);

      expect(stripped, {'User-Agent': 'blocked'});
      expect(headers.containsKey('User-Agent'), isFalse);
      expect(headers['Accept'], 'application/json');
    });
  });

  test('can disable raw logging for authenticated game traffic', () {
    final dio = createDio(
      connectivity: ConnectivityService(reachabilityProbe: () async => true),
      baseUrl: 'https://worker.example.test',
      enableLogging: false,
    );

    expect(
      dio.interceptors.any(
        (interceptor) => interceptor.runtimeType.toString() == 'LogInterceptor',
      ),
      isFalse,
    );
  });

  test('accepts explicit headers for the game API client', () {
    final dio = createDio(
      connectivity: ConnectivityService(reachabilityProbe: () async => true),
      baseUrl: 'https://worker.example.test',
      headers: const {'Accept': 'application/json'},
      enableLogging: false,
    );

    expect(dio.options.headers['Accept'], 'application/json');
    expect(dio.options.headers.containsKey('X-PokeData-Client'), isFalse);
    expect(dio.options.headers.containsKey('User-Agent'), isFalse);
  });
}
