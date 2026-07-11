import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/locale/api_load_target.dart';
import 'package:pokedex_app/core/locale/network_error_l10n.dart';
import 'package:pokedex_app/core/network/network_errors.dart';
import 'package:pokedex_app/l10n/generated/app_localizations_en.dart';
import 'package:pokedex_app/l10n/generated/app_localizations_pt.dart';

void main() {
  final l10nEn = AppLocalizationsEn();
  final l10nPt = AppLocalizationsPt();

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
        () => mapDioException(error, loadTarget: ApiLoadTarget.pokemon),
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
        () => mapDioException(error, loadTarget: ApiLoadTarget.pokemon),
        throwsA(isA<NetworkException>()),
      );
    });

    test('maps HTTP 503 to ServiceUnavailableException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/pokemon'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/pokemon'),
          statusCode: 503,
        ),
      );

      expect(
        () => mapDioException(error, loadTarget: ApiLoadTarget.pokemon),
        throwsA(
          isA<ServiceUnavailableException>().having(
            (e) => e.statusCode,
            'statusCode',
            503,
          ),
        ),
      );
    });

    test('maps HTTP 429 to ServiceUnavailableException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/pokemon'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/pokemon'),
          statusCode: 429,
        ),
      );

      expect(
        () => mapDioException(error, loadTarget: ApiLoadTarget.pokemon),
        throwsA(
          isA<ServiceUnavailableException>().having(
            (e) => e.statusCode,
            'statusCode',
            429,
          ),
        ),
      );
    });
  });

  group('isConnectivityFailure', () {
    test('returns false for ApiException', () {
      const error = ApiException(
        loadTarget: ApiLoadTarget.pokemon,
        statusCode: 400,
      );

      expect(isConnectivityFailure(error), isFalse);
    });

    test('returns true for NetworkException', () {
      const error = NetworkException();

      expect(isConnectivityFailure(error), isTrue);
    });
  });

  group('friendlyErrorMessage', () {
    test('localizes ApiException with status code', () {
      const error = ApiException(
        loadTarget: ApiLoadTarget.pokemon,
        statusCode: 400,
      );

      expect(
        friendlyErrorMessage(l10nPt, error),
        l10nPt.errorLoadDataWithStatus(400),
      );
    });

    test('localizes network failures', () {
      const error = NetworkException();

      expect(friendlyErrorMessage(l10nEn, error), l10nEn.errorNetworkOffline);
    });

    test('localizes 429 as too many requests', () {
      const error = ServiceUnavailableException(statusCode: 429);

      expect(
        friendlyErrorMessage(l10nPt, error),
        l10nPt.errorTooManyRequests,
      );
    });

    test('localizes 503 as service unavailable', () {
      const error = ServiceUnavailableException(statusCode: 503);

      expect(
        friendlyErrorMessage(l10nEn, error),
        l10nEn.errorServiceUnavailable,
      );
    });

    test('localizes egg group and item load targets', () {
      expect(
        apiLoadTargetMessage(l10nPt, ApiLoadTarget.eggGroup),
        l10nPt.errorLoadEggGroup,
      );
      expect(
        apiLoadTargetMessage(l10nEn, ApiLoadTarget.item),
        l10nEn.errorLoadItem,
      );
    });
  });
}
