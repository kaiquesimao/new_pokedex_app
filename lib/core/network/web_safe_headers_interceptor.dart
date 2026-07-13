import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Headers that browsers block on XHR/fetch (see fetch spec forbidden header names).
const forbiddenWebRequestHeaders = <String>{
  'accept-charset',
  'accept-encoding',
  'access-control-request-headers',
  'access-control-request-method',
  'connection',
  'content-length',
  'cookie',
  'cookie2',
  'date',
  'dnt',
  'expect',
  'host',
  'keep-alive',
  'origin',
  'referer',
  'te',
  'trailer',
  'transfer-encoding',
  'upgrade',
  'user-agent',
  'via',
};

/// Strips browser-forbidden headers and returns removed entries for logging.
Map<String, dynamic> stripForbiddenWebHeaders(Map<String, dynamic> headers) {
  final stripped = <String, dynamic>{};

  for (final key in headers.keys.toList()) {
    if (!forbiddenWebRequestHeaders.contains(key.toLowerCase())) {
      continue;
    }
    stripped[key] = headers[key];
    headers.remove(key);
  }

  return stripped;
}

/// Strips browser-forbidden headers on web and logs them in Dart.
class WebSafeHeadersInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!kIsWeb) {
      handler.next(options);
      return;
    }

    final stripped = stripForbiddenWebHeaders(options.headers);
    for (final entry in stripped.entries) {
      developer.log(
        'Removed forbidden header on web: ${entry.key} (value: ${entry.value})',
        name: 'network.web',
        level: 900,
      );
    }

    handler.next(options);
  }
}
