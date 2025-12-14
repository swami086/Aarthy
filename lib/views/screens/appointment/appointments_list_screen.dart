import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import '../../widgets/appointment_card.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_space_app/models/user_profile.dart';

class AppointmentsListScreen extends ConsumerWidget {
  const AppointmentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider); // Watch profile

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
          actions: [
            profileAsync.when(
              data: (profile) {
                 if (profile?.role == UserRole.mentor) {
                   return IconButton(
                     icon: const Icon(Icons.edit_calendar),
                     tooltip: 'Manage Availability',
                     onPressed: () => context.push('/mentor-availability'),
                   );
                 }
                 return const SizedBox();
              },
              loading: () => const SizedBox(),
              error: (_,__) => const SizedBox(),
            ),
            IconButton(
               icon: const Icon(Icons.refresh),
               onPressed: () => ref.refresh(userAppointmentsProvider),
            )
          ],
        ),
        body: const TabBarView(
          children: [
            _AppointmentList(isUpcoming: true),
            _AppointmentList(isUpcoming: false),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/mentors'), // Go to find mentors
          label: const Text('Book New'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _AppointmentList extends ConsumerWidget {
  final bool isUpcoming;

  const _AppointmentList({required this.isUpcoming});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = isUpcoming ? upcomingAppointmentsProvider : pastAppointmentsProvider;
    final appointmentsAsync = ref.watch(provider);

    return appointmentsAsync.when(
      data: (appointments) {
        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isUpcoming ? Icons.calendar_today : Icons.history, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  isUpcoming ? "No upcoming appointments" : "No past appointments",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(userAppointmentsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return AppointmentCard(
                appointment: appt,
                onTap: () => context.push('/appointment/${appt.id}'),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}
