import 'package:dio/dio.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';

class OfflineGuardInterceptor(final ConnectivityService _connectivity)
    extends Interceptor {
  static const offlineMessage = 'Device is offline';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_connectivity.isOnline) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: offlineMessage,
        ),
      );
      return;
    }

    handler.next(options);
  }
}
