import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_space_app/models/review.dart';
import 'package:safe_space_app/services/review/review_service.dart';
import 'package:safe_space_app/viewmodels/providers/auth_providers.dart';

// Provider for ReviewService
final reviewServiceProvider = Provider<ReviewService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ReviewService(client);
});

// Check if review exists for appointment
final existingReviewProvider = FutureProvider.family<Review?, String>((ref, appointmentId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(reviewServiceProvider).checkExistingReview(appointmentId, user.id);
});

// Top reviews for home screen
final topReviewsProvider = FutureProvider.family<List<Review>, int>((ref, limit) async {
  return ref.watch(reviewServiceProvider).getTopReviews(limit);
});

