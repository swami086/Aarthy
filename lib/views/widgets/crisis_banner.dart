import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CrisisBanner extends StatelessWidget {
  const CrisisBanner({super.key});

  Future<void> _launchDialer() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '988',
    );
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.red.withValues(alpha: 0.1) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.red.shade800 : Colors.red.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded, // Using rounded variant for softer look
            color: isDark ? Colors.red.shade400 : Colors.red.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In crisis? Please don\'t wait.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.red.shade100 : Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: _launchDialer,
                  child: Text(
                    'Call 988 for Suicide & Crisis Lifeline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                      decoration: TextDecoration.underline,
                    ),
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
