import 'package:dio/dio.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';

class OfflineGuardInterceptor extends Interceptor {
  OfflineGuardInterceptor(this._connectivity);

  final ConnectivityService _connectivity;

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
