import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:safe_space_app/utils/constants/app_colors.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'package:safe_space_app/services/notification/notification_service.dart';
import 'package:safe_space_app/models/appointment.dart';
import '../../widgets/appointment_status_chip.dart';
import 'package:go_router/go_router.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentAsync = ref.watch(appointmentByIdProvider(appointmentId));

    return Scaffold(
      appBar: AppBar(title: const Text("Appointment Details")),
      body: appointmentAsync.when(
        data: (appt) {
          if (appt == null) return const Center(child: Text("Appointment not found"));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Session Details", style: Theme.of(context).textTheme.headlineSmall),
                    AppointmentStatusChip(status: appt.status),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Participants
                _ParticipantSection(appointment: appt),
                
                const Divider(height: 48),
                
                // Date & Time
                _DetailRow(icon: Icons.calendar_today, label: "Date", value: DateFormat.yMMMMEEEEd().format(appt.startTime)),
                const SizedBox(height: 16),
                _DetailRow(icon: Icons.access_time, label: "Time", value: "${DateFormat.jm().format(appt.startTime)} - ${DateFormat.jm().format(appt.endTime)}"),
                 const SizedBox(height: 16),
                if (appt.notes != null && appt.notes!.isNotEmpty)
                   _DetailRow(icon: Icons.note, label: "Notes", value: appt.notes!),

                const SizedBox(height: 48),

                // Actions
                _buildActions(context, ref, appt),

              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, Appointment appt) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox();
    
    final isMentor = user.id == appt.mentorId;
    final otherUserId = isMentor ? appt.menteeId : appt.mentorId;
    
    return Column(
      children: [
        // Message button for both roles
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/chat/$otherUserId'),
            icon: const Icon(Icons.message),
            label: Text(isMentor ? 'Message Mentee' : 'Message Mentor'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Role-specific actions
        if (isMentor) ..._buildMentorActions(context, ref, appt),
        if (!isMentor) ...[
          if (appt.canBeCancelled) _buildCancelButton(context, ref, appt),
          if (appt.status == AppointmentStatus.completed)
            _buildReviewButton(context, ref, appt),
        ],
      ],
    );
  }

  Widget _buildReviewButton(BuildContext context, WidgetRef ref, Appointment appt) {
    final existingReviewAsync = ref.watch(existingReviewProvider(appt.id));

    return existingReviewAsync.when(
      data: (review) {
        if (review != null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Text(
              "Review Submitted ✓",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              context.push(
                '/review-submission/${appt.id}',
                extra: appt.mentorId,
              );
            },
            icon: const Icon(Icons.star),
            label: const Text("Leave a Review"),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }

  List<Widget> _buildMentorActions(BuildContext context, WidgetRef ref, Appointment appt) {
    if (appt.status == AppointmentStatus.pending) {
      return [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _updateStatus(context, ref, appt, AppointmentStatus.confirmed),
            child: const Text("Confirm Appointment"),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
               padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _updateStatus(context, ref, appt, AppointmentStatus.cancelled),
            child: const Text("Decline Appointment"),
          ),
        ),
      ];
    } else if (appt.status == AppointmentStatus.confirmed && appt.endTime.isBefore(DateTime.now())) {
      return [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _updateStatus(context, ref, appt, AppointmentStatus.completed),
            child: const Text("Mark as Completed"),
          ),
        ),
      ];
    }
    
    return [];
  }
  
  Widget _buildCancelButton(BuildContext context, WidgetRef ref, Appointment appt) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () => _confirmCancel(context, ref, appt),
        child: const Text("Cancel Appointment"),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, Appointment appt, AppointmentStatus newStatus) async {
    try {
      await ref.read(appointmentServiceProvider).updateAppointmentStatus(appt.id, newStatus);
      ref.refresh(userAppointmentsProvider);
      ref.invalidate(appointmentByIdProvider(appt.id)); // Force refresh detail
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Appointment ${newStatus.name}")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref, Appointment appt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Cancel Appointment?"),
        content: const Text("Are you sure you want to cancel this session? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(appointmentServiceProvider).cancelAppointment(appt.id);
        
        // Cancel notification
        await NotificationService().cancelNotification(appt.id.hashCode);
        
        ref.refresh(userAppointmentsProvider); // Refresh list
        if (context.mounted) Navigator.pop(context); // Go back
      } catch (e) {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to cancel: $e")));
        }
      }
    }
  }
}

class _ParticipantSection extends ConsumerWidget {
  final Appointment appointment;
  const _ParticipantSection({required this.appointment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show both mentor and mentee
    final mentorAsync = ref.watch(userProfileProvider(appointment.mentorId));
    final menteeAsync = ref.watch(userProfileProvider(appointment.menteeId));

    return Column(
      children: [
        _UserTile(title: "Mentor", userAsync: mentorAsync),
        const SizedBox(height: 16),
        _UserTile(title: "Mentee", userAsync: menteeAsync),
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  final String title;
  final AsyncValue userAsync;

  const _UserTile({required this.title, required this.userAsync});

  @override
  Widget build(BuildContext context) {
    return userAsync.when(
      data: (user) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
          child: user?.avatarUrl == null ? Text(user?.displayName[0] ?? '?') : null,
        ),
        title: Text(user?.displayName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(title),
      ),
      loading: () => const ListTile(title: LinearProgressIndicator()),
      error: (_,__) => const SizedBox(),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }
}
