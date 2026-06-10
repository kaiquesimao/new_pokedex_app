import 'package:dio/dio.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';

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

Never mapDioException(DioException error, {required String fallback}) {
  final statusCode = error.response?.statusCode;
  if (statusCode == 404) {
    throw const NotFoundException('Recurso não encontrado.');
  }

  if (_isDioNetworkFailure(error)) {
    throw NetworkException(error.message ?? fallback);
  }

  if (error.type == DioExceptionType.badResponse && statusCode != null) {
    throw ApiException(
      'Não foi possível carregar os dados ($statusCode). Tente novamente.',
      statusCode: statusCode,
    );
  }

  throw ApiException(error.message ?? fallback);
}

String friendlyErrorMessage(Object error) {
  if (error is OfflineEmptyCacheException) {
    return error.message;
  }
  if (isNetworkError(error)) {
    return 'Sem conexão com a internet.';
  }
  if (error is AppException) {
    return error.message;
  }
  return 'Algo deu errado. Tente novamente.';
}
