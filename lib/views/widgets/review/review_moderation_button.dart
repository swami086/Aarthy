import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'package:safe_space_app/models/review.dart';
import 'package:safe_space_app/models/user_profile.dart';

class ReviewModerationButton extends ConsumerWidget {
  final Review review;

  const ReviewModerationButton({super.key, required this.review});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return userAsync.when(
      data: (user) {
        // Only show if user is logged in.
        // In future, check for user.role == UserRole.admin
        if (user == null) return const SizedBox();

        return IconButton(
          icon: const Icon(Icons.flag_outlined, size: 20, color: Colors.grey),
          tooltip: 'Flag as inappropriate',
          onPressed: () => _flagReview(context, ref),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Future<void> _flagReview(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Flag Review?"),
        content: const Text("Are you sure you want to flag this review for moderation?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Flag", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(reviewServiceProvider).flagReview(review.id);

        // Invalidate providers to reflect changes
        // Assuming we want to refresh the list where this review appears
        ref.invalidate(mentorReviewsProvider(review.mentorId));
        // Also invalidate top reviews if it might be there (though unlikely if flagged, or maybe we hide flagged ones?)
        // The service doesn't hide flagged ones explicitly in getTopReviews, but UI might want to show them differently.
        ref.invalidate(topReviewsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review flagged for moderation.")));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }
}
