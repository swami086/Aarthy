import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:safe_space_app/utils/constants/app_colors.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_space_app/models/focus_area.dart';
import '../../widgets/review/review_card.dart';
import '../../widgets/review_moderation_button.dart';
import '../../widgets/error_message.dart';
import '../../widgets/loading_overlay.dart';

class MentorProfileScreen extends ConsumerWidget {
  final String mentorId;

  const MentorProfileScreen({super.key, required this.mentorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusAreasAsync = ref.watch(focusAreasProvider);
    final profileAsync = ref.watch(userProfileProvider(mentorId));
    final reviewsAsync = ref.watch(mentorReviewsProvider(mentorId));
    final ratingAsync = ref.watch(mentorAverageRatingProvider(mentorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Profile'),
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: Text('Mentor not found'));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: profile.avatarUrl != null
                              ? CachedNetworkImageProvider(profile.avatarUrl!)
                              : null,
                          child: profile.avatarUrl == null
                              ? Text(profile.displayName[0], style: const TextStyle(fontSize: 40, color: AppColors.primary))
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.displayName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ratingAsync.when(
                          data: (rating) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                rating > 0 ? rating.toStringAsFixed(1) : 'New',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              reviewsAsync.maybeWhen(
                                data: (reviews) => Text('(${reviews.length} reviews)', style: const TextStyle(color: Colors.grey)),
                                orElse: () => const SizedBox(),
                              ),
                            ],
                          ),
                          error: (_,__) => const SizedBox(),
                          loading: () => const SizedBox(),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: profile.expertiseAreas.map((areaId) {
                             final label = focusAreasAsync.maybeWhen(
                               data: (areas) => areas.firstWhere((a) => a.id == areaId, orElse: () => FocusArea(id: areaId, name: areaId, icon: '')).name,
                               orElse: () => areaId,
                             );
                             return Chip(
                               label: Text(label),
                               backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                               labelStyle: const TextStyle(color: AppColors.primary),
                               side: BorderSide.none,
                             );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Divider(),
                
                // About
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        profile.bio ?? 'No bio available.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Reviews
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       reviewsAsync.when(
                         data: (reviews) => Row(
                           children: [
                             Text('Reviews', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                             const SizedBox(width: 8),
                             Text('(${reviews.length})', style: const TextStyle(color: Colors.grey)),
                           ],
                         ),
                         error: (_,__) => const SizedBox(),
                         loading: () => const SizedBox(),
                       ),
                       const SizedBox(height: 16),
                       reviewsAsync.when(
                         data: (reviews) {
                           if (reviews.isEmpty) return const Text('No reviews yet.');
                           return SizedBox(
                             height: 180, // rough height for reviews
                             child: ListView.separated(
                               scrollDirection: Axis.horizontal,
                               itemCount: reviews.length,
                               separatorBuilder: (_,__) => const SizedBox(width: 16),
                               itemBuilder: (context, index) => ReviewCard(
                                 review: reviews[index],
                                 trailing: ReviewModerationButton(review: reviews[index]),
                               ),
                             ),
                           );
                         },
                         loading: () => const Center(child: CircularProgressIndicator()),
                         error: (e,__) => ErrorMessage(
                           message: 'Could not load reviews.',
                           onRetry: () => ref.refresh(mentorReviewsProvider(mentorId)),
                         ),
                       ),
                    ],
                  ),
                ),

                // Availability Placeholder
                 Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Availability', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.grey),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('View calendar and book a session')),
                            OutlinedButton.icon(
                              onPressed: () {
                                context.push('/chat/$mentorId');
                              },
                              icon: const Icon(Icons.message),
                              label: const Text('Message'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.push('/book-appointment/$mentorId');
                              }, 
                              child: const Text('Book Session'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => LoadingOverlay(isLoading: true, child: SizedBox.expand()),
        error: (e, st) => ErrorMessage(message: e.toString(), onRetry: () => ref.refresh(userProfileProvider(mentorId))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           // Chat with mentor
        },
        icon: const Icon(Icons.chat_bubble),
        label: const Text('Message'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
