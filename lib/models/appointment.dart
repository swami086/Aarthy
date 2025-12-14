import 'package:flutter/material.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled }

class Appointment {
  final String id;
  final String mentorId;
  final String menteeId;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Add getters for related user info if joined, but keeping model simple for now
  
  const Appointment({
    required this.id,
    required this.mentorId,
    required this.menteeId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      mentorId: json['mentor_id'] as String,
      menteeId: json['mentee_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String).toLocal(), // Handle T-Z conversion
      endTime: DateTime.parse(json['end_time'] as String).toLocal(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
        orElse: () => AppointmentStatus.pending,
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mentor_id': mentorId,
      'mentee_id': menteeId,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'status': status.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? mentorId,
    String? menteeId,
    DateTime? startTime,
    DateTime? endTime,
    AppointmentStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      menteeId: menteeId ?? this.menteeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Duration get duration => endTime.difference(startTime);

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isPast => endTime.isBefore(DateTime.now());

  bool get canBeCancelled {
    if (status == AppointmentStatus.cancelled || status == AppointmentStatus.completed) {
      return false;
    }
    // Allow cancellation if > 24 hours before start
    return startTime.difference(DateTime.now()).inHours >= 24;
  }

  Color get statusColor {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }
}
