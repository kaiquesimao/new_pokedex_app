import 'package:dio/dio.dart';

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://pokeapi.co/api/v2',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: false,
      responseBody: false,
    ),
  );

  return dio;
}
