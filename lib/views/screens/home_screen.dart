import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/constants/app_colors.dart';
import '../../viewmodels/viewmodels.dart';
import '../widgets/hero_section.dart';
import '../widgets/focus_area_card.dart';
import '../widgets/crisis_banner.dart';
import '../widgets/legal_disclaimer.dart';
import '../widgets/review/review_card.dart';
import '../../models/focus_area.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers
    final focusAreasAsync = ref.watch(focusAreasProvider);
    final mentorsAsync = ref.watch(mentorsProvider);
    final topReviewsAsync = ref.watch(topReviewsProvider(3));

    // Using a consistent scroll controller for effects if needed
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      extendBodyBehindAppBar: true, // For blur effect overlap
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        centerTitle: false,
        title: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.spa, color: Colors.white, size: 24),
        ),
        actions: [
          // Chat with unread badge
          ref.watch(unreadCountProvider).when(
            data: (count) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => context.push('/chats'),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count > 9 ? '9+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            loading: () => IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => context.push('/chats'),
            ),
            error: (_, __) => IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => context.push('/chats'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => context.push('/appointments'),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // TODO: Open sidebar/drawer or navigate to settings
               ref.read(authViewModelProvider.notifier).signOut(); // For now, keep sign out accessible but hidden-ish
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480), // Mobile-first design constrain
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.only(top: 80, bottom: 100), // Adjusted for FAB
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeroSection(),
                
                // CTA Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                             // Start conversation / Chat
                          },
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Start a Conversation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Free 15-min intro • Mentorship & Coaching',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Areas of Focus
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Areas of Focus', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const Text('Swipe →', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180, // Card height needs to accommodate content
                  child: focusAreasAsync.when(
                    data: (focusAreas) {
                      if (focusAreas.isEmpty) return const Center(child: Text('Coming soon'));
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: focusAreas.length,
                        itemBuilder: (context, index) {
                          return FocusAreaCard(
                            focusArea: focusAreas[index],
                            onTap: () {
                               // Navigate to mentor listing with filter
                               // Using Uri encoding to handle spaces (though IDs shouldn't need it as much, good practice)
                               context.push('/mentors?filter=${Uri.encodeComponent(focusAreas[index].id)}');
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Failed to load: $e')),
                  ),
                ),

                const SizedBox(height: 40),

                // Info Card "From School to College"
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From School to College',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Navigating transitions can be tough. We help you build the skills to thrive in new environments.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      // Decorative Element
                       Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school, size: 30, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Relatable Mentors Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Relatable Mentors', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.push('/mentors'),
                  child: Container(
                     margin: const EdgeInsets.symmetric(horizontal: 16),
                     height: 60, // Height for avatar stack
                     child: mentorsAsync.when(
                       data: (mentors) {
                         // Take up to 4 mentors
                         final displayMentors = mentors.take(4).toList();
                         if (displayMentors.isEmpty) return const Text('No mentors yet.');

                         return Stack(
                           children: [
                             for (int i = 0; i < displayMentors.length; i++)
                               Positioned(
                                 left: i * 40.0, // Overlap
                                 child: CircleAvatar(
                                   radius: 28, // 56px diam
                                   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                   child: CircleAvatar(
                                     radius: 26,
                                     backgroundImage: displayMentors[i].avatarUrl != null 
                                         ? CachedNetworkImageProvider(displayMentors[i].avatarUrl!)
                                         : null,
                                     child: displayMentors[i].avatarUrl == null
                                         ? Text(displayMentors[i].displayName[0])
                                         : null,
                                   ),
                                 ),
                               ),
                             // +40 Badge equivalent
                             Positioned(
                               left: displayMentors.length * 40.0,
                               child: Container(
                                 width: 56,
                                 height: 56,
                                 decoration: BoxDecoration(
                                   color: Theme.of(context).cardColor,
                                   shape: BoxShape.circle,
                                   border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                                   boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
                                 ),
                                 alignment: Alignment.center,
                                 child: const Text('+40', style: TextStyle(fontWeight: FontWeight.bold)),
                               ),
                             ),
                           ],
                         );
                       },
                       loading: () => const SizedBox(),
                       error: (_,__) => const SizedBox(),
                     ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.push('/mentors'),
                        child: const Row(
                          children: [
                            Text('Meet our mentors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Real people. Vetted for safety. Focused on your growth.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 40),
                
                // Testimonials
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('What Our Mentees Say', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 250, // Height to accommodate review cards
                  child: topReviewsAsync.when(
                    data: (reviews) {
                      if (reviews.isEmpty) {
                         // Fallback to hardcoded one if no reviews
                         return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              width: 320,
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                   BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 20),
                                      Icon(Icons.star, color: Colors.amber, size: 20),
                                      Icon(Icons.star, color: Colors.amber, size: 20),
                                      Icon(Icons.star, color: Colors.amber, size: 20),
                                      Icon(Icons.star, color: Colors.amber, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '"My mentor helped me realize that aiming for perfection was actually holding me back. I feel so much lighter now."',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.grey.withOpacity(0.1),
                                        child: const Text('J', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Jordan', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('High School Senior', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                      }

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          return ReviewCard(review: reviews[index]);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox(), // Hide if error
                  ),
                ),
                
                const SizedBox(height: 40),

                const CrisisBanner(),
                const LegalDisclaimer(),
                
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '© 2024 Safe Space. All rights reserved.', 
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           // Chat action
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
