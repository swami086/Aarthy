import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:safe_space_app/models/appointment.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'appointment_status_chip.dart';

class AppointmentCard extends ConsumerWidget {
  final Appointment appointment;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need to show the "other" person.
    // Ideally we fetch profiles in batch or this widget is smart.
    // For MVP, we'll assume the caller passes relevant info OR we fetch singular profile.
    // To keep it simple, let's fetch the "other" participant here.
    
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return const SizedBox();

    final isMeMentor = currentUser.id == appointment.mentorId;
    final otherUserId = isMeMentor ? appointment.menteeId : appointment.mentorId;
    
    final otherUserProfileAsync = ref.watch(userProfileProvider(otherUserId));

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  otherUserProfileAsync.when(
                    data: (profile) {
                         if (profile == null) return const CircleAvatar(child: Icon(Icons.person));
                         return CircleAvatar(
                           radius: 24,
                           backgroundImage: profile.avatarUrl != null ? CachedNetworkImageProvider(profile.avatarUrl!) : null,
                           child: profile.avatarUrl == null ? Text(profile.displayName[0]) : null,
                         );
                    },
                    loading: () => const CircleAvatar(child: Icon(Icons.person)),
                    error: (_,__) => const CircleAvatar(child: Icon(Icons.error)),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        otherUserProfileAsync.when(
                          data: (p) => Text(
                            p?.displayName ?? 'Unknown User',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          loading: () => Container(height: 16, width: 100, color: Colors.grey[300]),
                          error: (_,__) => const Text('User'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, y • h:mm a').format(appointment.startTime),
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // Status
                  AppointmentStatusChip(status: appointment.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
