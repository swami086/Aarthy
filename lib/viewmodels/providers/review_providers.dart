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

// StateNotifier for submission state (if we wanted to move logic out of UI)
// But for now, simple UI state in widget is enough as per implementation.
// Keeping provider structure for consistency.
class ReviewSubmissionState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  ReviewSubmissionState({this.isLoading = false, this.error, this.isSuccess = false});
}

class ReviewSubmissionNotifier extends StateNotifier<ReviewSubmissionState> {
  final ReviewService _service;

  ReviewSubmissionNotifier(this._service) : super(ReviewSubmissionState());

  Future<void> submit({
    required String mentorId,
    required String menteeId,
    required String appointmentId,
    required double rating,
    String? comment,
  }) async {
    state = ReviewSubmissionState(isLoading: true);
    try {
      await _service.submitReview(
        mentorId: mentorId,
        menteeId: menteeId,
        appointmentId: appointmentId,
        rating: rating,
        comment: comment,
      );
      state = ReviewSubmissionState(isSuccess: true);
    } catch (e) {
      state = ReviewSubmissionState(error: e.toString());
    }
  }
}

final reviewSubmissionProvider = StateNotifierProvider<ReviewSubmissionNotifier, ReviewSubmissionState>((ref) {
  final service = ref.watch(reviewServiceProvider);
  return ReviewSubmissionNotifier(service);
});
