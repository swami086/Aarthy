import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/review.dart';

class ReviewService {
  final SupabaseClient _client;

  ReviewService(this._client);

  Future<void> submitReview({
    required String mentorId,
    required String menteeId,
    required String appointmentId,
    required int rating,
    String? comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }

    // Check existing review
    final exists = await checkExistingReview(appointmentId, menteeId);
    if (exists != null) {
      throw Exception("You've already reviewed this session");
    }

    final reviewId = const Uuid().v4();
    final review = Review(
      id: reviewId,
      mentorId: mentorId,
      menteeId: menteeId,
      appointmentId: appointmentId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    try {
      await _client.from('reviews').insert(review.toJson());
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  Future<void> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    final updates = <String, dynamic>{};
    if (rating != null) {
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }
      updates['rating'] = rating;
    }
    if (comment != null) updates['comment'] = comment;

    if (updates.isEmpty) return;

    try {
      await _client.from('reviews').update(updates).eq('id', reviewId);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  Future<void> flagReview(String reviewId) async {
    try {
      await _client.from('reviews').update({'is_flagged': true}).eq('id', reviewId);
    } catch (e) {
      throw Exception('Failed to flag review: $e');
    }
  }

  Future<Review?> checkExistingReview(String appointmentId, String menteeId) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('appointment_id', appointmentId)
          .eq('mentee_id', menteeId)
          .maybeSingle();

      if (response == null) return null;
      return Review.fromJson(response);
    } catch (e) {
      throw Exception('Failed to check existing review: $e');
    }
  }

  Future<List<Review>> getTopReviews(int limit) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .gte('rating', 4) // Fetch 4 and 5 stars since we use int now
          .order('rating', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e) {
      // Return empty if table doesn't exist or other error
      print('Error fetching top reviews: $e');
      return [];
    }
  }
}
