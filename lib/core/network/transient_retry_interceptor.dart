import 'package:dio/dio.dart';

class TransientRetryInterceptor extends Interceptor {
  TransientRetryInterceptor({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const maxRetries = 1;
  static const retryDelay = Duration(milliseconds: 500);
  static const retryCountKey = 'transientRetryCount';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final retryCount = (options.extra[retryCountKey] as int?) ?? 0;

    if (retryCount >= maxRetries || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    options.extra[retryCountKey] = retryCount + 1;
    await Future<void>.delayed(retryDelay);

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      return statusCode == 502 || statusCode == 503 || statusCode == 504;
    }

    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError;
  }
}
