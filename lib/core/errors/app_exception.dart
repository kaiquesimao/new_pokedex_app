import 'package:pokedex_app/core/locale/api_load_target.dart';
import 'package:pokedex_app/core/locale/offline_cache_error_kind.dart';

sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException({this.loadTarget}) : super('');

  final ApiLoadTarget? loadTarget;
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

final class NotFoundException extends AppException {
  const NotFoundException() : super('');
}

final class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException({this.statusCode}) : super('');

  final int? statusCode;
}

final class ApiException extends AppException {
  const ApiException({this.loadTarget, this.statusCode}) : super('');

  final ApiLoadTarget? loadTarget;
  final int? statusCode;
}

final class OfflineEmptyCacheException extends AppException {
  const OfflineEmptyCacheException({
    this.kind = OfflineCacheErrorKind.emptyPokemonList,
    this.regionName,
  }) : super('');

  final OfflineCacheErrorKind kind;
  final String? regionName;
}
