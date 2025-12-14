import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_space_app/utils/constants/app_colors.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'package:safe_space_app/models/focus_area.dart';
import '../../widgets/mentor_card.dart';
import '../../widgets/error_message.dart';

// Hooks are great, but since I need ConsumerWidget for Riverpod, 
// I'll use HookConsumerWidget if flutter_hooks + riverpod_hooks are installed.
// Since riverpod_hooks wasn't explicitly added, I'll stick to ConsumerStatefulWidget or just ConsumerWidget with local state logic if simple.
// The plan suggested flutter_hooks or StatefulWidget. I'll use StatefulConsumerWidget to be safe without extra deps.

class MentorListingScreen extends ConsumerStatefulWidget {
  final String? initialFilter;

  const MentorListingScreen({super.key, this.initialFilter});

  @override
  ConsumerState<MentorListingScreen> createState() => _MentorListingScreenState();
}

class _MentorListingScreenState extends ConsumerState<MentorListingScreen> {
  String? selectedFilter;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final focusAreasAsync = ref.watch(focusAreasProvider);
    final mentorsAsync = ref.watch(filteredMentorsProvider(selectedFilter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Mentor'),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: focusAreasAsync.when(
              data: (focusAreas) {
                 return ListView(
                   scrollDirection: Axis.horizontal,
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   children: [
                     Padding(
                       padding: const EdgeInsets.only(right: 8),
                       child: FilterChip(
                         label: const Text('All'),
                         selected: selectedFilter == null,
                         onSelected: (selected) {
                           if (selected) {
                             setState(() => selectedFilter = null);
                           }
                         },
                         selectedColor: AppColors.primary.withOpacity(0.2),
                         checkmarkColor: AppColors.primary,
                       ),
                     ),
                     ...focusAreas.map((area) {
                       return Padding(
                         padding: const EdgeInsets.only(right: 8),
                         child: FilterChip(
                           label: Text(area.title),
                           selected: selectedFilter == area.id,
                           onSelected: (selected) {
                              setState(() {
                                selectedFilter = selected ? area.id : null;
                              });
                           },
                           selectedColor: AppColors.primary.withOpacity(0.2),
                           checkmarkColor: AppColors.primary,
                         ),
                       );
                     }),
                   ],
                 );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_,__) => const SizedBox(),
            ),
          ),
          
          Expanded(
            child: mentorsAsync.when(
              data: (mentors) {
                if (mentors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No mentors found for this filter.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                        if (selectedFilter != null)
                          TextButton(
                            onPressed: () => setState(() => selectedFilter = null),
                            child: const Text('Clear filters'),
                          ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400, // Responsive-ish
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: mentors.length,
                  itemBuilder: (context, index) {
                    final mentor = mentors[index];
                    final ratingAsync = ref.watch(mentorAverageRatingProvider(mentor.userId));
                    
                    return MentorCard(
                      mentor: mentor,
                      averageRating: ratingAsync.value, 
                      getExpertiseLabel: (id) {
                         // Simple lookup from async value if available
                         return focusAreasAsync.maybeWhen(
                           data: (areas) => areas.firstWhere((a) => a.id == id, orElse: () => FocusArea(id: id, name: id, icon: '')).name,
                           orElse: () => id,
                         );
                      },
                      onTap: () {
                        context.push('/mentor/${mentor.userId}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => ErrorMessage(message: e.toString(), onRetry: () => ref.refresh(filteredMentorsProvider(selectedFilter))),
            ),
          ),
        ],
      ),
    );
  }
}
