class RepositoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  RepositoryException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'RepositoryException: $message ${code != null ? "($code)" : ""}';
}

class AppAuthException extends RepositoryException {
  AppAuthException(super.message, {super.code, super.originalError});
}

class NetworkException extends RepositoryException {
  NetworkException(super.message, {super.code, super.originalError});
}
