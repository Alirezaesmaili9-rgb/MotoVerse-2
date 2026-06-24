/// Data-layer exceptions. Caught in repositories and mapped to [Failure]s.
class ServerException implements Exception {
  ServerException([this.message = 'Server error']);
  final String message;
}

class AuthException implements Exception {
  AuthException([this.message = 'Auth error']);
  final String message;
}

class CacheException implements Exception {
  CacheException([this.message = 'Cache error']);
  final String message;
}
