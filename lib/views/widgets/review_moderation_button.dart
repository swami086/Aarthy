import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'package:safe_space_app/models/review.dart';

class ReviewModerationButton extends ConsumerWidget {
  final Review review;

  const ReviewModerationButton({super.key, required this.review});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check for admin role
    // The previous implementation tried to access `user?.role.name` but `currentUserProvider` returns `User?` (Supabase User), not `UserProfile`.
    // Supabase `User` does not have `role` property in the way we defined in UserRole enum.
    // It has `app_metadata` or `user_metadata` or `role` (string, usually 'authenticated').
    // However, our app logic seems to store role in `profiles` table and `UserProfile` model.
    // So we should watch `currentUserProfileProvider` instead of `currentUserProvider` to get the app-specific role.

    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return userProfileAsync.when(
      data: (profile) {
         if (profile == null) return const SizedBox();
         // Check if role is admin.
         // Note: UserRole enum needs to have 'admin' or we check string if we can't modify enum easily.
         // But I will assume I can update UserRole enum or just check against the string name if I convert it.
         // Actually, I should update UserRole enum.

         // If I haven't updated UserRole yet, I should.
         final isAdmin = profile.role.name == 'admin';

         if (!isAdmin) return const SizedBox();

         return IconButton(
          icon: const Icon(Icons.flag_outlined, color: Colors.grey),
          tooltip: 'Flag Review',
          onPressed: () => _flagReview(context, ref),
        );
      },
      loading: () => const SizedBox(),
      error: (_,__) => const SizedBox(),
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Review flagged.")));
        }
        // Ideally refresh the review list or item
        // ref.refresh(topReviewsProvider(3));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }
}
