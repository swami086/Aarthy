import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/auth_exceptions.dart'; // Import AppAuthException
import 'providers/auth_providers.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final User? user;

  AuthState({this.status = AuthStatus.initial, this.errorMessage, this.user});

  AuthState copyWith({AuthStatus? status, String? errorMessage, User? user}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthViewModel(this._authService) : super(AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _authService.signInWithEmail(email, password);
      if (response.user == null) {
         state = state.copyWith(status: AuthStatus.error, errorMessage: "Login failed");
      } else {
         state = state.copyWith(status: AuthStatus.authenticated, errorMessage: null, user: response.user);
      }
    } on AppAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _authService.signUpWithEmail(email, password);
       if (response.user == null) {
         state = state.copyWith(status: AuthStatus.error, errorMessage: "Sign up failed");
      } else {
         state = state.copyWith(status: AuthStatus.authenticated, errorMessage: null, user: response.user);
      }
    } on AppAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final success = await _authService.signInWithGoogle();
      if (success) {
        state = state.copyWith(status: AuthStatus.authenticated, errorMessage: null, user: _authService.currentUser);
      } else {
        state = state.copyWith(status: AuthStatus.error, errorMessage: "Google Sign In failed");
      }
    } on AppAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

   Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _authService.signInWithApple();
      if (response.user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, errorMessage: null, user: response.user);
      } else {
        state = state.copyWith(status: AuthStatus.error, errorMessage: "Apple Sign In failed");
      }
    } on AppAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.signOut();
    } on AppAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }
  
  Future<void> resetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.resetPassword(email);
      state = state.copyWith(status: AuthStatus.initial); 
    } on AppAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }
  Future<void> updatePassword(String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.updatePassword(newPassword);
      state = state.copyWith(status: AuthStatus.authenticated, errorMessage: null);
    } on AppAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authServiceProvider));
});
