import 'package:flutter/material.dart';

class LegalDisclaimer extends StatelessWidget {
  const LegalDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.amber.shade900.withOpacity(0.2) : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.amber.shade800 : Colors.amber.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: isDark ? Colors.amber.shade500 : Colors.amber.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Legal Notice',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.amber.shade100 : Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Safe Space provides mentorship and coaching, not clinical therapy or medical advice. Our mentors are peers and professionals focused on growth, not licensed therapists. If you need medical attention, please contact a healthcare provider.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.amber.shade200 : Colors.amber.shade800,
                    height: 1.5,
                    fontSize: 11, // Slightly smaller for dense text
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
