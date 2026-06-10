import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/network/network_errors.dart';

void main() {
  group('mapDioException', () {
    test('maps HTTP 400 to ApiException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/pokemon'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/pokemon'),
          statusCode: 400,
        ),
      );

      expect(
        () => mapDioException(error, fallback: 'fallback'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('maps connection errors to NetworkException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/pokemon'),
        type: DioExceptionType.connectionError,
        message: 'Device is offline',
      );

      expect(
        () => mapDioException(error, fallback: 'fallback'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('isConnectivityFailure', () {
    test('returns false for ApiException', () {
      const error = ApiException('API failed', statusCode: 400);

      expect(isConnectivityFailure(error), isFalse);
    });

    test('returns true for NetworkException', () {
      const error = NetworkException('Device is offline');

      expect(isConnectivityFailure(error), isTrue);
    });
  });

  group('friendlyErrorMessage', () {
    test('shows API message for ApiException', () {
      const error = ApiException(
        'Não foi possível carregar os dados (400). Tente novamente.',
        statusCode: 400,
      );

      expect(
        friendlyErrorMessage(error),
        'Não foi possível carregar os dados (400). Tente novamente.',
      );
    });

    test('shows offline message only for network failures', () {
      const error = NetworkException('Device is offline');

      expect(friendlyErrorMessage(error), 'Sem conexão com a internet.');
    });
  });
}
