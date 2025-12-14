import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'package:safe_space_app/utils/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class MentorAvailabilityScreen extends ConsumerStatefulWidget {
  const MentorAvailabilityScreen({super.key});

  @override
  ConsumerState<MentorAvailabilityScreen> createState() => _MentorAvailabilityScreenState();
}

class _MentorAvailabilityScreenState extends ConsumerState<MentorAvailabilityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Fetch booked slots for the focused month
    final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    
    final bookedSlotsAsync = ref.watch(mentorBookedSlotsProvider((
      mentorId: user.id,
      start: startOfMonth,
      end: endOfMonth
    )));

    return Scaffold(
      appBar: AppBar(title: const Text('My Availability')),
      body: Column(
        children: [
          bookedSlotsAsync.when(
            data: (slots) {
              return TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: AppColors.primary.withOpacity(0.5), shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  markerDecoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
                eventLoader: (day) {
                  // Simple logic: if any slot falls on this day
                  return slots.where((slot) {
                    final start = DateTime.parse(slot['start_time']).toLocal();
                    return isSameDay(start, day);
                  }).toList();
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading calendar: $e')),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Sessions for ${DateFormat('MMM d').format(_selectedDay ?? _focusedDay)}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                bookedSlotsAsync.when(
                  data: (slots) {
                    final daySlots = slots.where((slot) {
                       final start = DateTime.parse(slot['start_time']).toLocal();
                       return isSameDay(start, _selectedDay);
                    }).toList();

                    if (daySlots.isEmpty) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No sessions scheduled."),
                      ));
                    }

                    return Column(
                      children: daySlots.map((slot) {
                         final start = DateTime.parse(slot['start_time']).toLocal();
                         final end = DateTime.parse(slot['end_time']).toLocal();
                         return ListTile(
                           leading: const Icon(Icons.access_time),
                           title: Text("${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}"),
                           subtitle: Text(slot['status'] == 'cancelled' ? 'Blocked/Cancelled' : 'Booked'), // Status might need better mapping
                           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                           // can navigate to detail if we have ID, but RPC might not return ID. 
                           // If RPC returns ID, we can link. RPC usually returns id in select *
                         );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_,__) => const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder for "Block Time" feature
          showModalBottomSheet(
             context: context,
             builder: (c) => Container(
               padding: const EdgeInsets.all(16),
               height: 250,
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text("Manage Availability", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 16),
                   ListTile(
                     leading: const Icon(Icons.block, color: Colors.red),
                     title: const Text("Block Time Slot"),
                     subtitle: const Text("Prevent bookings for a specific time"),
                     onTap: () async {
                       Navigator.pop(c);
                       
                       // 1. Pick Start Time
                       final time = await showTimePicker(
                         context: context,
                         initialTime: const TimeOfDay(hour: 9, minute: 0),
                         helpText: "Select Start Time",
                       );
                       
                       if (time == null) return;

                       if (!context.mounted) return;

                       // 2. Pick End Time (or default duration, but let's be flexible)
                        final endTimeVal = await showTimePicker(
                         context: context,
                         initialTime: TimeOfDay(hour: time.hour + 1, minute: time.minute),
                         helpText: "Select End Time",
                       );

                       if (endTimeVal == null) return;
                       
                       // Construct DateTimes
                       final now = DateTime.now();
                       final selectedDate = _selectedDay ?? now;
                       
                       final startDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, time.hour, time.minute);
                       final endDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endTimeVal.hour, endTimeVal.minute);

                       if (endDateTime.isBefore(startDateTime)) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("End time must be after start time")));
                          return;
                       }
                       
                       // Call service
                       try {
                         await ref.read(appointmentServiceProvider).blockTimeSlot(
                           mentorId: user.id,
                           startTime: startDateTime,
                           endTime: endDateTime,
                         );
                         
                         // Refresh
                         ref.refresh(mentorBookedSlotsProvider((
                            mentorId: user.id,
                            start: DateTime(selectedDate.year, selectedDate.month, 1),
                            end: DateTime(selectedDate.year, selectedDate.month + 1, 0),
                         )));

                         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Time slot blocked successfully")));
                       } catch (e) {
                         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to block: $e")));
                       }
                     },
                   ),
                 ],
               ),
             ),
          );
        },
        child: const Icon(Icons.edit_calendar),
      ),
    );
  }
}
