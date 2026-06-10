import 'package:dio/dio.dart';
import 'package:pokedex_app/core/errors/app_exception.dart';

bool isNetworkError(Object error) {
  if (error is NetworkException) return true;
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.unknown;
  }

  final message = error.toString().toLowerCase();
  return message.contains('socketexception') ||
      message.contains('failed host lookup') ||
      message.contains('network is unreachable') ||
      message.contains('connection errored') ||
      message.contains('device is offline');
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
