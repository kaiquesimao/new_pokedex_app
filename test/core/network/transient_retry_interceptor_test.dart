import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/network/transient_retry_interceptor.dart';

void main() {
  test('retries once on 503 then succeeds', () async {
    final dio = Dio();
    var calls = 0;
    dio.httpClientAdapter = _StatusSequenceAdapter(
      onFetch: () {
        calls++;
        return calls == 1 ? 503 : 200;
      },
    );
    dio.interceptors.add(TransientRetryInterceptor(dio: dio));

    final response = await dio.get<dynamic>('/pokemon/1');

    expect(response.statusCode, 200);
    expect(calls, 2);
  });

  test('does not retry on 429', () async {
    final dio = Dio();
    var calls = 0;
    dio.httpClientAdapter = _StatusSequenceAdapter(
      onFetch: () {
        calls++;
        return 429;
      },
    );
    dio.interceptors.add(TransientRetryInterceptor(dio: dio));

    await expectLater(
      dio.get<dynamic>('/pokemon/1'),
      throwsA(isA<DioException>()),
    );
    expect(calls, 1);
  });

  test('stops after maxRetries', () async {
    final dio = Dio();
    var calls = 0;
    dio.httpClientAdapter = _StatusSequenceAdapter(
      onFetch: () {
        calls++;
        return 503;
      },
    );
    dio.interceptors.add(TransientRetryInterceptor(dio: dio));

    await expectLater(
      dio.get<dynamic>('/pokemon/1'),
      throwsA(isA<DioException>()),
    );
    expect(calls, 2);
  });
}

class _StatusSequenceAdapter implements HttpClientAdapter {
  _StatusSequenceAdapter({required this.onFetch});

  final int Function() onFetch;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final statusCode = onFetch();
    if (statusCode >= 400) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: statusCode,
        ),
      );
    }
    return ResponseBody.fromString('{}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }
}
