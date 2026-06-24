class AppException implements Exception {
  final String message;
  final dynamic cause;

  AppException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'AppException: $message — $cause';
    }
    return 'AppException: $message';
  }
}

class PermissionException extends AppException {
  PermissionException(String message) : super(message);
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message);
}
