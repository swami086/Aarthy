class AppAuthException implements Exception {
  final String message;
  final String? code;

  AppAuthException(this.message, {this.code});

  @override
  String toString() => 'AppAuthException: $message';
}

class InvalidCredentialsException extends AppAuthException {
  InvalidCredentialsException({String? message})
      : super(message ?? 'Invalid email or password', code: 'invalid_credentials');
}

class UserAlreadyExistsException extends AppAuthException {
  UserAlreadyExistsException({String? message})
      : super(message ?? 'An account with this email already exists',
            code: 'user_already_exists');
}

class NetworkException extends AppAuthException {
  NetworkException({String? message})
      : super(message ?? 'Please check your internet connection', code: 'network_error');
}
