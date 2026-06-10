import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/network/offline_guard_interceptor.dart';

class _FakeConnectivityService extends ConnectivityService {
  _FakeConnectivityService({required bool isOnline}) : _isOnline = isOnline;

  bool _isOnline;

  @override
  bool get isOnline => _isOnline;

  set isOnline(bool value) => _isOnline = value;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  test('OfflineGuardInterceptor rejects requests when offline', () async {
    final connectivity = _FakeConnectivityService(isOnline: false);
    final dio = Dio();
    dio.interceptors.add(OfflineGuardInterceptor(connectivity));

    expect(
      () => dio.get<dynamic>('https://pokeapi.co/api/v2/pokemon'),
      throwsA(
        isA<DioException>().having(
          (error) => error.message,
          'message',
          OfflineGuardInterceptor.offlineMessage,
        ),
      ),
    );
  });

  test('OfflineGuardInterceptor allows requests when online', () async {
    final connectivity = _FakeConnectivityService(isOnline: true);
    final dio = Dio();
    dio.interceptors.add(OfflineGuardInterceptor(connectivity));
    dio.httpClientAdapter = _RejectingAdapter();

    expect(
      () => dio.get<dynamic>('https://pokeapi.co/api/v2/pokemon'),
      throwsA(isA<DioException>()),
    );
  });
}

class _RejectingAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      message: 'adapter reached',
    );
  }
}
