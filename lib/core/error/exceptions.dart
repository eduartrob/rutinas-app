class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);
}

class NetworkException implements Exception {
  final String? message;
  NetworkException([this.message]);
}

class BadRequestException implements Exception {
  final String? message;
  BadRequestException([this.message]);
}

class UnauthorizedException implements Exception {
  final String? message;
  UnauthorizedException([this.message]);
}

class NotFoundException implements Exception {
  final String? message;
  NotFoundException([this.message]);
}

class UnknownException implements Exception {
  final String? message;
  UnknownException([this.message]);
}

class ConflictException implements Exception {
  final String? message;
  ConflictException([this.message]);
}
