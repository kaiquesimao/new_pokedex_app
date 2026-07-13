import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/network/offline_guard_interceptor.dart';
import 'package:pokedex_app/core/network/transient_retry_interceptor.dart';
import 'package:pokedex_app/core/network/web_safe_headers_interceptor.dart';

const _appName = 'PokeData';
const _projectUrl = 'https://pokedata.kaique.site';

/// Client identification string for PokéAPI fair-use policy.
String pokeApiClientId(String version) =>
    '$_appName/$version (Flutter; +$_projectUrl)';

/// Builds default PokéAPI request headers for the current platform.
Map<String, String> pokeApiRequestHeaders({
  required String appVersion,
  bool isWeb = kIsWeb,
}) {
  final clientId = pokeApiClientId(appVersion);
  return {
    'Accept': 'application/json',
    if (isWeb) 'X-PokeData-Client': clientId else 'User-Agent': clientId,
  };
}

Dio createDio({
  required ConnectivityService connectivity,
  String appVersion = '1.0.0',
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://pokeapi.co/api/v2',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: kIsWeb ? null : const Duration(seconds: 15),
      // ponytail: explicit per network-resilience spec (default is json).
      // ignore: avoid_redundant_argument_values
      responseType: ResponseType.json,
      headers: pokeApiRequestHeaders(appVersion: appVersion),
    ),
  );

  dio.interceptors.add(OfflineGuardInterceptor(connectivity));
  dio.interceptors.add(TransientRetryInterceptor(dio: dio));
  dio.interceptors.add(WebSafeHeadersInterceptor());

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(),
    );
  }

  return dio;
}
