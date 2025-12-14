import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/appointment.dart';

class AppointmentService {
  final SupabaseClient _client;

  AppointmentService(this._client);

  /// Fetch appointments for a user (either as mentor or mentee)
  Future<List<Appointment>> getUserAppointments(String userId, {AppointmentStatus? statusFilter}) async {
    try {
      var query = _client.from('appointments').select();
      
      // OR filter: mentor_id.eq.userId, mentee_id.eq.userId
      // Supabase "or" syntax: or=(mentor_id.eq.uuid,mentee_id.eq.uuid)
      query = query.or('mentor_id.eq.$userId,mentee_id.eq.$userId');

      if (statusFilter != null) {
        query = query.eq('status', statusFilter.name);
      }

      final response = await query.order('start_time', ascending: true);

      return (response as List<dynamic>)
          .map((json) => Appointment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  /// Create a new appointment
  Future<Appointment> createAppointment({
    required String mentorId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // 1. Check availability
    final isAvailable = await checkAvailability(mentorId, startTime, endTime);
    if (!isAvailable) {
      throw Exception('Booking conflict: Mentor is unavailable at this time.');
    }

    try {
      final response = await _client.from('appointments').insert({
        'mentor_id': mentorId,
        'mentee_id': user.id,
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'status': AppointmentStatus.pending.name, // Default status
        'notes': notes,
      }).select().single();

      return Appointment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  /// Block a time slot (Mentor self-booking/blocking)
  Future<Appointment> blockTimeSlot({
    required String mentorId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // Insert with status 'cancelled' and note 'Blocked by mentor' as per requirements
    // Skippping checkAvailability to allow self-blocking
    try {
      final response = await _client.from('appointments').insert({
        'mentor_id': mentorId,
        'mentee_id': mentorId, // Self-reference
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'status': 'cancelled', 
        'notes': 'Blocked by mentor',
      }).select().single();

      return Appointment.fromJson(response);
    } catch (e) {
      throw Exception('Failed to block slot: $e');
    }
  }

  /// Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus newStatus) async {
    try {
      await _client.from('appointments').update({
        'status': newStatus.name,
      }).eq('id', appointmentId);
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    await updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
  }

  /// Get booked slots for a mentor within a date range
  Future<List<Map<String, dynamic>>> getMentorBookedSlots(
      String mentorId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _client.rpc('get_mentor_booked_slots', params: {
        'p_mentor_id': mentorId,
        'p_start_date': startDate.toUtc().toIso8601String(),
        'p_end_date': endDate.toUtc().toIso8601String(),
      });
      
      // Returns list of {start_time, end_time, status}
      // We can let the UI parse this or map it to a simple DTO
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // If RPC fails or returns error, return empty list or throw
      // Ideally handle gracefully
      return []; 
    }
  }

  /// Check if a time slot is available
  Future<bool> checkAvailability(String mentorId, DateTime startTime, DateTime endTime) async {
    try {
      final response = await _client.rpc('check_mentor_availability', params: {
        'p_mentor_id': mentorId,
        'p_start_time': startTime.toUtc().toIso8601String(),
        'p_end_time': endTime.toUtc().toIso8601String(),
      });
      return response as bool;
    } catch (e) {
      // If check fails, assume unavailable for safety
      return false;
    }
  }
}
