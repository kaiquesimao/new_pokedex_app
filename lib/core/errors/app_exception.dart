import 'package:pokedex_app/core/locale/api_load_target.dart';
import 'package:pokedex_app/core/locale/offline_cache_error_kind.dart';

sealed class const AppException(final String message) implements Exception {
  @override
  String toString() => message;
}

final class const NetworkException({final ApiLoadTarget? loadTarget})
    extends AppException {
  this : super('');
}

final class const CacheException([super.message = 'Cache error'])
    extends AppException;

final class const NotFoundException() extends AppException {
  this : super('');
}

final class const ServiceUnavailableException({final int? statusCode})
    extends AppException {
  this : super('');
}

final class const ApiException({
  final ApiLoadTarget? loadTarget,
  final int? statusCode,
}) extends AppException {
  this : super('');
}

final class const OfflineEmptyCacheException({
  final OfflineCacheErrorKind kind = OfflineCacheErrorKind.emptyPokemonList,
  final String? regionName,
}) extends AppException {
  this : super('');
}
