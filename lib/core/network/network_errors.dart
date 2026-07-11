import 'package:dio/dio.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';
import 'package:pokedex_app/core/locale/api_load_target.dart';

export 'package:pokedex_app/core/locale/network_error_l10n.dart'
    show friendlyErrorMessage;

bool isConnectivityFailure(Object error) {
  return error is OfflineEmptyCacheException || isNetworkError(error);
}

bool isNetworkError(Object error) {
  if (error is NetworkException) {
    return true;
  }
  if (error is DioException) {
    return _isDioNetworkFailure(error);
  }

  final message = error.toString().toLowerCase();
  return message.contains('socketexception') ||
      message.contains('failed host lookup') ||
      message.contains('network is unreachable') ||
      message.contains('connection errored') ||
      message.contains('device is offline');
}

bool _isDioNetworkFailure(DioException error) {
  return error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      (error.type == DioExceptionType.unknown && error.response == null);
}

Never mapDioException(
  DioException error, {
  required ApiLoadTarget loadTarget,
}) {
  final statusCode = error.response?.statusCode;
  if (statusCode == 404) {
    throw const NotFoundException();
  }

  if (_isDioNetworkFailure(error)) {
    throw NetworkException(loadTarget: loadTarget);
  }

  if (statusCode == 429 ||
      statusCode == 502 ||
      statusCode == 503 ||
      statusCode == 504) {
    throw ServiceUnavailableException(statusCode: statusCode);
  }

  if (error.type == DioExceptionType.badResponse && statusCode != null) {
    throw ApiException(loadTarget: loadTarget, statusCode: statusCode);
  }

  throw ApiException(loadTarget: loadTarget);
}
