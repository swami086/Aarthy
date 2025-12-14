import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_profile.dart';
import '../../utils/constants/app_colors.dart';

class MentorCard extends StatelessWidget {
  final UserProfile mentor;
  final double? averageRating;
  final String Function(String)? getExpertiseLabel;
  final VoidCallback? onTap;

  const MentorCard({
    super.key,
    required this.mentor,
    this.averageRating,
    this.onTap,
    this.getExpertiseLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // ... (lines 23-104)
        elevation: Theme.of(context).cardTheme.elevation ?? 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   // ... Avatar ...
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: mentor.avatarUrl != null
                        ? CachedNetworkImageProvider(mentor.avatarUrl!)
                        : null,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: mentor.avatarUrl == null
                        ? Text(
                            mentor.displayName.isNotEmpty ? mentor.displayName[0].toUpperCase() : 'M',
                            style: const TextStyle(fontSize: 20, color: AppColors.primary),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mentor.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (averageRating != null && averageRating! > 0)
                          Row(
                            children: [
                                Row(
                                    children: List.generate(5, (index) {
                                      if (index < averageRating!.floor()) {
                                        return const Icon(Icons.star, size: 14, color: Colors.amber);
                                      } 
                                      return Icon(
                                          index < averageRating!.round() ? Icons.star : Icons.star_border,
                                          size: 14,
                                          color: Colors.amber
                                      );
                                    }),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  averageRating!.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                            ],
                          )
                        else
                          Row(
                            children: [
                               Row(children: List.generate(5, (_) => const Icon(Icons.star_border, size: 14, color: Colors.amber))),
                               const SizedBox(width: 4),
                               const Text('New', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: mentor.expertiseAreas.take(3).map((areaId) {
                  final label = getExpertiseLabel != null ? getExpertiseLabel!(areaId) : areaId;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
