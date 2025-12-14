import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../viewmodels/viewmodels.dart';
import '../../utils/constants/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Minimum Splash duration
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    
    // Check if we are in the middle of a password recovery flow (deep link with code)
    // If so, we stay here and let the AppRouter's auth listener handle the direction 
    // to UpdatePasswordScreen once the event fires.
    final uri = GoRouterState.of(context).uri;
    final hasCode = uri.queryParameters.containsKey('code');
    final hasHashToken = uri.fragment.contains('type=recovery') || uri.fragment.contains('access_token');

    if (hasCode || hasHashToken) {
      debugPrint('Recovery code or implicit token detected in Splash, waiting for auth event...');
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    
    if (session != null) {
      try {
        // User is authenticated, check profile
        final profile = await ref.read(userProfileProvider(session.user.id).future);
        
        if (!mounted) return;

        if (profile != null) {
          context.go('/home');
        } else {
          context.go('/profile-setup');
        }
      } catch (e) {
        debugPrint('Error fetching profile in splash: $e');
        if (mounted) {
           // Fallback to login or show error? Retrying might be better but for now safety fallback.
           // Actually, if we are auth'd but profile fetch fails (network), maybe showing error is better than logout.
           // But user asked to navigate to safe fallback like login.
           context.go('/login');
        }
      }
    } else {
      // Not authenticated
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
             Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
               child: const Icon(Icons.security, size: 64, color: AppColors.primary), 
             ),
            const SizedBox(height: 24),
            const Text(
              'Safe Space',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
