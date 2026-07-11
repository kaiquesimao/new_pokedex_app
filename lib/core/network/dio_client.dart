import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pokedex_app/core/network/connectivity_service.dart';
import 'package:pokedex_app/core/network/offline_guard_interceptor.dart';

const _appName = 'PokeData';
const _projectUrl = 'https://pokedata.kaique.site';

/// HTTP User-Agent sent to PokéAPI (fair-use identification).
String pokeApiUserAgent(String version) =>
    '$_appName/$version (Flutter; +$_projectUrl)';

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
      headers: {
        'Accept': 'application/json',
        'User-Agent': pokeApiUserAgent(appVersion),
      },
    ),
  );

  dio.interceptors.add(OfflineGuardInterceptor(connectivity));

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(),
    );
  }

  return dio;
}
