import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'package:safe_space_app/services/notification/notification_service.dart';
import 'package:safe_space_app/utils/constants/app_colors.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  final String mentorId;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;

  const BookingConfirmationScreen({
    super.key,
    required this.mentorId,
    required this.startTime,
    required this.endTime,
    this.notes
  });

  @override
  ConsumerState<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends ConsumerState<BookingConfirmationScreen> {
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.notes != null) {
      _notesController.text = widget.notes!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    setState(() => _isSubmitting = true);
    try {
      final service = ref.read(appointmentServiceProvider);
      
      final appointment = await service.createAppointment(
        mentorId: widget.mentorId,
        startTime: widget.startTime,
        endTime: widget.endTime,
        notes: _notesController.text,
      );

      // Schedule notification
      await NotificationService().scheduleAppointmentNotification(appointment);
      
      if (!mounted) return;

      // Show success and navigate
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: const Text("Booking Confirmed!"),
          content: const Text("Your session has been scheduled successfully."),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(); // Close dialog
                context.go('/appointments'); // Go to list
              },
              child: const Text("View Appointments"),
            )
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentorAsync = ref.watch(userProfileProvider(widget.mentorId));

    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Booking")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mentorAsync.when(
              data: (p) => Row(
                children: [
                   CircleAvatar(
                     radius: 30,
                     backgroundImage: p?.avatarUrl != null ? NetworkImage(p!.avatarUrl!) : null,
                     child: p?.avatarUrl == null ? Text(p?.displayName[0] ?? 'M') : null,
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(p?.displayName ?? 'Mentor', style: Theme.of(context).textTheme.titleLarge),
                         Text(p?.role.name ?? 'Mentor', style: const TextStyle(color: Colors.grey)),
                       ],
                     ),
                   )
                ],
              ),
              loading: () => const LinearProgressIndicator(), 
              error: (_,__) => const SizedBox(),
            ),
            const SizedBox(height: 32),
            
            _InfoRow(icon: Icons.calendar_today, text: DateFormat('EEEE, MMMM d, y').format(widget.startTime)),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.access_time, text: "${DateFormat('h:mm a').format(widget.startTime)} - ${DateFormat('h:mm a').format(widget.endTime)}"),
            const SizedBox(height: 16),
            const _InfoRow(icon: Icons.timer, text: "60 Minutes"),
            
            const SizedBox(height: 32),
            
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: "Notes for Mentor (Optional)",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Confirm Booking", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
