import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_space_app/models/review.dart';
import 'package:safe_space_app/utils/constants/app_colors.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'package:safe_space_app/viewmodels/providers/review_providers.dart';

class ReviewSubmissionScreen extends ConsumerStatefulWidget {
  final String appointmentId;
  final String mentorId;

  const ReviewSubmissionScreen({
    super.key,
    required this.appointmentId,
    required this.mentorId,
  });

  @override
  ConsumerState<ReviewSubmissionScreen> createState() => _ReviewSubmissionScreenState();
}

class _ReviewSubmissionScreenState extends ConsumerState<ReviewSubmissionScreen> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating < 1) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception("User not authenticated");
      }

      await ref.read(reviewServiceProvider).submitReview(
            mentorId: widget.mentorId,
            menteeId: user.id,
            appointmentId: widget.appointmentId,
            rating: _rating.toInt(),
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          );

      // Invalidate relevant providers to refresh data
      ref.invalidate(mentorReviewsProvider(widget.mentorId));
      ref.invalidate(mentorAverageRatingProvider(widget.mentorId));
      ref.invalidate(existingReviewProvider(widget.appointmentId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
        context.pop(); // Go back to appointment detail
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentorAsync = ref.watch(userProfileProvider(widget.mentorId));

    return Scaffold(
      appBar: AppBar(title: const Text("Leave a Review")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mentor Info
            mentorAsync.when(
              data: (mentor) => Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: mentor?.avatarUrl != null
                        ? NetworkImage(mentor!.avatarUrl!)
                        : null,
                    child: mentor?.avatarUrl == null
                        ? Text(mentor != null && mentor.displayName.isNotEmpty
                            ? mentor.displayName[0]
                            : '?',
                            style: const TextStyle(fontSize: 32))
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Rate your session with ${mentor?.displayName ?? 'Mentor'}",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 32),

            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 40,
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _rating > 0 ? "$_rating/5" : "Tap stars to rate",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Comment Field
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: "Share your experience (optional)...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                onPressed: _rating > 0 && !_isSubmitting ? _submitReview : null,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Submit Review"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
