import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_space_app/utils/constants/app_colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Helper for rich text
    TextSpan primaryText(String text) {
      return TextSpan(
        text: text,
        style: TextStyle(color: colorScheme.primary),
      );
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.background.withOpacity(0.95),
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.spa, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 8),
            Text('Safe Space', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // TODO: Implement drawer or settings navigation
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onBackground),
                        children: [
                          const TextSpan(text: 'A place to be heard, '),
                          primaryText('not analyzed.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Life coaching and active listening for when you just need to talk. No diagnosis, just support.',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        Chip(
                          label: const Text('Not Therapy'),
                          avatar: Icon(Icons.check_circle, color: colorScheme.primary),
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                        ),
                        Chip(
                          label: const Text('Life Coaching'),
                          avatar: Icon(Icons.favorite, color: colorScheme.primary),
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24.0),
                      child: Image.asset('assets/images/hero_image.png'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/signup'),
                        icon: const Icon(Icons.chat_bubble),
                        label: const Text('Connect with a Listener', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Free 15-min intro session • No credit card needed',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Why are we here?', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Swipe →', style: textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    FocusAreaCard(
                      icon: Icons.air,
                      iconBgColor: Colors.orange.shade100,
                      iconColor: Colors.orange.shade500,
                      title: 'Just Vent',
                      description: 'Release the pressure valve. Talk about school, friends, or life without fear of judgment.',
                    ),
                    FocusAreaCard(
                      icon: Icons.explore,
                       iconBgColor: Colors.purple.shade100,
                      iconColor: Colors.purple.shade500,
                      title: 'Find Direction',
                      description: 'Feeling lost? Our coaches help you map out your next steps and set achievable goals.',
                    ),
                     FocusAreaCard(
                      icon: Icons.hearing,
                       iconBgColor: Colors.green.shade100,
                      iconColor: Colors.green.shade500,
                      title: 'Unbiased Ear',
                      description: "We aren't your parents or your teachers. We're just here to listen to your side.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'For Students & Teens',
                        style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Whether you're stressing about finals, friendship drama, or just feeling \"off\"—we're here. We are mentors, not doctors.",
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () { /* TODO: Implement navigation */ },
                        child: Row(
                          children: [
                            Text('Learn how it works', style: textTheme.bodyLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, color: colorScheme.primary, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meet a few listeners', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Image.asset('assets/images/mentors.png'), // Simplified from HTML
                    const SizedBox(height: 8),
                    Text(
                      'Real people. Vetted mentors. Available 24/7.',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
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
                          '"I was scared to talk to a therapist, but this felt just like talking to a cool older sibling. I feel so much lighter."',
                          style: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.secondaryContainer,
                              child: Text('A', style: TextStyle(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Text('Alex, College Sophomore', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                     const Divider(),
                     const SizedBox(height: 24),
                     Text.rich(
                      TextSpan(
                         children: [
                          TextSpan(text: 'Disclaimer: ', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'Safe Space is not a medical service. We do not diagnose or treat mental health disorders.'),
                         ],
                      ),
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                     ),
                     const SizedBox(height: 16),
                      Container(
                         padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                         child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'In crisis? Please don\'t wait.\n'),
                              TextSpan(
                                text: 'Call 988 for Suicide & Crisis Lifeline',
                                style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: colorScheme.onErrorContainer),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onErrorContainer),
                        ),
                       ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/signup'),
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.chat, color: colorScheme.onPrimary),
      ),
    );
  }
}

class FocusAreaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconBgColor;
  final Color iconColor;

  const FocusAreaCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.iconBgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Container(
             width: 40,
             height: 40,
             decoration: BoxDecoration(
               color: iconBgColor,
               shape: BoxShape.circle,
             ),
             child: Icon(icon, color: iconColor, size: 24),
           ),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
