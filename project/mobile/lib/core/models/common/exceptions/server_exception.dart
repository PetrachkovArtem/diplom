class ServerException implements Exception {
  ServerException(this.message, this.code);

  final String message;
  final int code;

  @override
  String toString() => message;
}
