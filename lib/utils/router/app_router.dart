import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile.dart';
import '../../views/screens/splash_screen.dart';
import '../../views/screens/auth/login_screen.dart';
import '../../views/screens/auth/signup_screen.dart';
import '../../views/screens/auth/forgot_password_screen.dart';
import '../../views/screens/profile/profile_setup_screen.dart';
import '../../views/screens/profile/edit_profile_screen.dart';
import '../../views/screens/auth/update_password_screen.dart';
import '../../views/screens/home_screen.dart';
import '../../views/screens/mentor/mentor_listing_screen.dart';
import '../../views/screens/mentor/mentor_profile_screen.dart';
import '../../views/screens/appointment/appointments_list_screen.dart';
import '../../views/screens/appointment/appointment_detail_screen.dart';
import '../../views/screens/appointment/mentor_availability_screen.dart';
import '../../views/screens/appointment/booking_calendar_screen.dart';
import '../../views/screens/appointment/time_slot_selection_screen.dart';
import '../../views/screens/appointment/booking_confirmation_screen.dart';
import '../../views/screens/chat/chat_list_screen.dart';
import '../../views/screens/chat/chat_detail_screen.dart';
import '../../views/screens/review/review_submission_screen.dart';
import '../../viewmodels/viewmodels.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUserProfileAsync = ref.watch(currentUserProfileProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateProvider.stream)),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
       GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
       GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/update-password',
        builder: (context, state) => const UpdatePasswordScreen(),
      ),
      GoRoute(
        path: '/mentors',
        builder: (context, state) {
           final filter = state.uri.queryParameters['filter'];
           return MentorListingScreen(initialFilter: filter);
        },
      ),
      GoRoute(
        path: '/mentor/:mentorId',
        builder: (context, state) {
           final mentorId = state.pathParameters['mentorId']!;
           return MentorProfileScreen(mentorId: mentorId);
        },
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentsListScreen(),
      ),
      GoRoute(
        path: '/appointment/:appointmentId',
        builder: (context, state) => AppointmentDetailScreen(appointmentId: state.pathParameters['appointmentId']!),
      ),
      GoRoute(
        path: '/mentor-availability',
        builder: (context, state) => const MentorAvailabilityScreen(),
      ),
      GoRoute(
        path: '/book-appointment/:mentorId',
        builder: (context, state) => BookingCalendarScreen(mentorId: state.pathParameters['mentorId']!),
      ),
      GoRoute(
        path: '/book-appointment/:mentorId/select-time',
        builder: (context, state) {
           final mentorId = state.pathParameters['mentorId']!;
           final selectedDate = state.extra as DateTime;
           return TimeSlotSelectionScreen(mentorId: mentorId, selectedDate: selectedDate);
        },
      ),
      GoRoute(
        path: '/book-appointment/:mentorId/confirm',
        builder: (context, state) {
           final mentorId = state.pathParameters['mentorId']!;
           final data = state.extra as Map<String, dynamic>;
           return BookingConfirmationScreen(
             mentorId: mentorId,
             startTime: data['startTime'],
             endTime: data['endTime'],
             notes: data['notes'],
           );
        },
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final profile = state.extra as UserProfile?;
          return ChatDetailScreen(
            otherUserId: userId,
            otherUserProfile: profile,
          );
        },
      ),
      GoRoute(
        path: '/review-submission/:appointmentId',
        builder: (context, state) {
          final appointmentId = state.pathParameters['appointmentId']!;
          // Use query parameter as fallback for web, or extra for direct navigation flow
          final mentorId = (state.extra as String?) ?? state.uri.queryParameters['mentorId'];

          if (mentorId == null) {
            // Fallback error or redirect if no mentorId provided
            return const Scaffold(body: Center(child: Text("Invalid navigation state")));
          }

          return ReviewSubmissionScreen(appointmentId: appointmentId, mentorId: mentorId);
        },
      ),
    ],
    redirect: (context, state) async {
       // AuthState is from supabase, has session.
       final session = authState.value?.session;
       final event = authState.value?.event;
       final user = session?.user;
       final bool loggedIn = user != null;

       if (event == AuthChangeEvent.passwordRecovery && state.uri.path != '/update-password') {
         return '/update-password';
       }

       final path = state.uri.path;
       
       // Allow access if processing a recovery code (Supabase sends code parameter)
       // This prevents redirecting to login while the SDK is exchanging the code.
       final hasRecoveryCode = state.uri.queryParameters.containsKey('code');

       final isLoggingIn = path == '/login' ||
           path == '/signup' ||
           path == '/forgot-password' ||
           path == '/splash' ||
           path == '/update-password' ||
           path == '/'; // Allow root to load for auth checks

       if (!loggedIn && !isLoggingIn && !hasRecoveryCode) {
         return '/login';
       }
       
       // Handle already logged in but visiting auth pages
       if (loggedIn && (path == '/login' || path == '/signup' || path == '/forgot-password')) {
         return '/home'; 
       }

       // Mentor only routes
       if (path == '/mentor-availability') {
          final profile = currentUserProfileAsync.value;
          // If profile not loaded yet, maybe wait or allow? 
          // Safest to redirect if we know they aren't a mentor.
          // For now, if profile is null (still loading), we might let them through or show loading.
          // Let's assume initialized.
          if (profile != null && profile.role != UserRole.mentor) {
            return '/home';
          }
       }
       
       return null;
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
