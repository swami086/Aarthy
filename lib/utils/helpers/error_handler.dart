import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error is AuthException) {
      if (error.message.contains('Invalid login credentials')) {
        return 'Invalid email or password.';
      }
      if (error.message.contains('User already registered')) {
        return 'An account with this email already exists.';
      }
      return error.message; 
    }
    return error.toString();
  }
}
