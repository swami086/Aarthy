import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              children: [
                const TextSpan(text: 'Mentoring for the '),
                TextSpan(
                  text: 'real you.',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Connect with mentors who\'ve been there. No judgment, just real talk about school, life, and everything in between.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[300] 
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: [
              _buildBadge(context, Icons.verified_user, 'Mentoring'),
              _buildBadge(context, Icons.self_improvement, 'Growth'),
              _buildBadge(context, Icons.block, 'Not Therapy'),
            ],
          ),
          const SizedBox(height: 32),
          // Hero Image
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [AppColors.primary, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Pattern or Illustration placeholder
                 Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    Icons.diversity_3,
                    size: 200,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                        ],
                      ),
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

  Widget _buildBadge(BuildContext context, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label),
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.grey[800] 
          : Colors.white,
      side: BorderSide(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[700]! 
            : Colors.grey[200]!,
      ),
    );
  }
}
