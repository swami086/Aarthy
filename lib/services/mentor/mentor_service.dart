import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile.dart';
import '../../models/review.dart';

class MentorService {
  final SupabaseClient _client;

  MentorService(this._client);

  Future<List<UserProfile>> getMentors({String? expertiseFilter}) async {
    try {
      var query = _client
          .from('profiles')
          .select()
          .eq('role', 'mentor');

      if (expertiseFilter != null && expertiseFilter.isNotEmpty) {
        query = query.contains('expertise_areas', [expertiseFilter]);
      }

      final response = await query.order('created_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch mentors: $e');
    }
  }

  Future<List<Review>> getMentorReviews(String mentorId) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('mentor_id', mentorId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e) {
      // Return empty list if table doesn't exist yet or other error, 
      // but ideally we should handle specific errors. 
      // For now, assuming reviews table exists or will exist.
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  Future<double> getMentorAverageRating(String mentorId) async {
    final reviews = await getMentorReviews(mentorId);
    return Review.getAverageRating(reviews);
  }
}
