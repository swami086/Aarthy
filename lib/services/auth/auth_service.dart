import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_service.dart';
import 'auth_exceptions.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  GoTrueClient get _auth => SupabaseService.client.auth;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;
  
  User? get currentUser => _auth.currentUser;

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final response = await _auth.signUp(email: email, password: password);
      return response;
    } on AuthException catch (e) {
      throw _handleSupabaseError(e);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _handleSupabaseError(e);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }
  
  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        return await _auth.signInWithOAuth(OAuthProvider.google);
      } else {
        const webClientId = 'YOUR_WEB_CLIENT_ID'; // TODO: Update with actual Client ID
        const iosClientId = 'YOUR_IOS_CLIENT_ID'; // TODO: Update with actual Client ID
        
        final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId: defaultTargetPlatform == TargetPlatform.iOS ? iosClientId : null,
          serverClientId: webClientId,
        );
        
        final googleUser = await googleSignIn.signIn();
        final googleAuth = await googleUser?.authentication;
        
        if (googleAuth == null) {
          throw AppAuthException('Google Sign In failed');
        }
        
        final accessToken = googleAuth.accessToken;
        final idToken = googleAuth.idToken;
        
        if (idToken == null) {
          throw AppAuthException('No ID Token found.');
        }

        final response = await _auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        
        return response.session != null;
      }
    } on AuthException catch (e) {
      throw _handleSupabaseError(e);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<AuthResponse> signInWithApple() async {
    try {
      final rawNonce = _generateRandomString();
      final hashedNonce = _sha256(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw AppAuthException('Could not find ID Token from generated credential.');
      }

      final response = await _auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      
      if (credential.givenName != null || credential.familyName != null) {
        await _auth.updateUser(
          UserAttributes(
            data: {
              'full_name': '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim(),
            },
          ),
        );
      }
      
      return response;
    } on AuthException catch (e) {
      throw _handleSupabaseError(e);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
       throw _handleSupabaseError(e);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? Uri.base.origin : null,
      );
    } on AuthException catch (e) {
      throw _handleSupabaseError(e);
    } catch (e) {
      throw AppAuthException(e.toString());
    }
  }

  Exception _handleSupabaseError(dynamic error) {
    if (error is AuthException) {
      if (error.message.contains('Invalid login credentials')) {
        return InvalidCredentialsException();
      } else if (error.message.contains('User already registered')) {
        return UserAlreadyExistsException();
      }
      return AppAuthException(error.message, code: error.statusCode);
    }
    return AppAuthException('An unexpected error occurred: ${error.toString()}');
  }

  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(32, (_) => random.nextInt(256)));
  }

  String _sha256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}
