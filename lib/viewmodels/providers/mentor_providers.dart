import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/mentor/mentor_service.dart';
import '../../models/user_profile.dart';
import '../../models/review.dart';

final mentorServiceProvider = Provider<MentorService>((ref) {
  return MentorService(Supabase.instance.client);
});

final mentorsProvider = FutureProvider<List<UserProfile>>((ref) async {
  final service = ref.watch(mentorServiceProvider);
  return service.getMentors();
});

final filteredMentorsProvider = FutureProvider.family<List<UserProfile>, String?>((ref, expertiseFilter) async {
  final service = ref.watch(mentorServiceProvider);
  return service.getMentors(expertiseFilter: expertiseFilter);
});

final mentorReviewsProvider = FutureProvider.family<List<Review>, String>((ref, mentorId) async {
  final service = ref.watch(mentorServiceProvider);
  return service.getMentorReviews(mentorId);
});

final mentorAverageRatingProvider = FutureProvider.family<double, String>((ref, mentorId) async {
  final service = ref.watch(mentorServiceProvider);
  return service.getMentorAverageRating(mentorId);
});
