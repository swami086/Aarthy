import 'package:flutter/material.dart';
import 'package:safe_space_app/models/appointment.dart';

class AppointmentStatusChip extends StatelessWidget {
  final AppointmentStatus status;

  const AppointmentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case AppointmentStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case AppointmentStatus.confirmed:
        color = Colors.green;
        label = 'Confirmed';
        break;
      case AppointmentStatus.completed:
        color = Colors.blue;
        label = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
