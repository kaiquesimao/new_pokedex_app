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
