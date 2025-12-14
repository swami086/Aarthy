import 'package:flutter/material.dart';
import '../../models/focus_area.dart';
import '../../utils/constants/app_colors.dart';

class FocusAreaCard extends StatelessWidget {
  final FocusArea focusArea;
  final VoidCallback? onTap;

  const FocusAreaCard({
    super.key,
    required this.focusArea,
    this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'checkroom':
        return Icons.checkroom;
      case 'diversity_3':
        return Icons.diversity_3;
      case 'spa':
        return Icons.spa;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'psychology':
        return Icons.psychology;
      case 'school':
        return Icons.school;
      default:
        return Icons.spa;
    }
  }

  Color _getIconBackgroundColor(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Map titles to some consistent colors if possible, or cycle
    if (title.contains('Style')) return isDark ? Colors.purple.shade900 : Colors.purple.shade50;
    if (title.contains('Social')) return isDark ? Colors.blue.shade900 : Colors.blue.shade50;
    if (title.contains('Mindfulness')) return isDark ? Colors.teal.shade900 : Colors.teal.shade50;
    if (title.contains('Future')) return isDark ? Colors.orange.shade900 : Colors.orange.shade50;
    
    return isDark ? Colors.grey.shade800 : Colors.grey.shade100;
  }
  
  Color _getIconColor(String title) {
    if (title.contains('Style')) return Colors.purple;
    if (title.contains('Social')) return Colors.blue;
    if (title.contains('Mindfulness')) return Colors.teal;
    if (title.contains('Future')) return Colors.orange;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(context, focusArea.title),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(focusArea.icon ?? ''),
                    color: _getIconColor(focusArea.title),
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  focusArea.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  focusArea.description ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
