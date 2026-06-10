sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

final class ApiException extends AppException {
  const ApiException(super.message, {this.statusCode});

  final int? statusCode;
}

final class OfflineEmptyCacheException extends AppException {
  const OfflineEmptyCacheException([
    super.message =
        'Sem conexão e nenhum Pokémon salvo no dispositivo.\n'
        'Conecte-se uma vez para baixar a Pokédex.',
  ]);
}
