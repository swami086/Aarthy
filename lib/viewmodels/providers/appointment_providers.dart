import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/appointment.dart';
import '../../services/appointment/appointment_service.dart';
import 'auth_providers.dart';

// Service Provider
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService(Supabase.instance.client);
});

// User Appointments (Mentee & Mentor mixed view)
final userAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final service = ref.watch(appointmentServiceProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  return service.getUserAppointments(user.id);
});

// Upcoming Appointments
final upcomingAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final allAppointments = await ref.watch(userAppointmentsProvider.future);
  
  return allAppointments.where((appt) => 
    appt.isUpcoming && 
    appt.status != AppointmentStatus.cancelled
  ).toList();
});

// Past Appointments
final pastAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final allAppointments = await ref.watch(userAppointmentsProvider.future);
  
  return allAppointments.where((appt) => appt.isPast).toList();
});

// Specific Appointment Details
final appointmentByIdProvider = FutureProvider.family<Appointment?, String>((ref, id) async {
  final allAppointments = await ref.watch(userAppointmentsProvider.future);
  try {
    return allAppointments.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
});

// Mentor Booked Slots (for Calendar)
final mentorBookedSlotsProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String mentorId, DateTime start, DateTime end})>((ref, params) async {
  final service = ref.watch(appointmentServiceProvider);
  return service.getMentorBookedSlots(params.mentorId, params.start, params.end);
});
