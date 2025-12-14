import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'package:safe_space_app/utils/constants/app_colors.dart';

class BookingCalendarScreen extends ConsumerStatefulWidget {
  final String mentorId;

  const BookingCalendarScreen({super.key, required this.mentorId});

  @override
  ConsumerState<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends ConsumerState<BookingCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    // Fetch details about mentor just for header visual
    final mentorProfileAsync = ref.watch(userProfileProvider(widget.mentorId));

    // Fetch availability
    final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final bookedSlotsAsync = ref.watch(mentorBookedSlotsProvider((
      mentorId: widget.mentorId,
      start: startOfMonth,
      end: endOfMonth
    )));

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Column(
        children: [
          // Mentor Info Header
          mentorProfileAsync.when(
            data: (p) => ListTile(
              leading: CircleAvatar(backgroundImage: p?.avatarUrl != null ? NetworkImage(p!.avatarUrl!) : null, child: p?.avatarUrl == null ? Text(p?.displayName[0] ?? 'M') : null),
              title: Text("Book with ${p?.displayName ?? 'Mentor'}"),
              subtitle: const Text("Select a date"),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_,__) => const SizedBox(),
          ),
          
          bookedSlotsAsync.when(
            data: (slots) {
              return TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  // Navigate to time selection
                  context.push(
                    '/book-appointment/${widget.mentorId}/select-time', 
                    extra: selectedDay
                  );
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
                enabledDayPredicate: (day) {
                  // Disable past dates
                  if (day.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                    return false;
                  }
                  
                  // Filter based on booked slots
                  // Count appointments on this day
                  // Assuming slots is List<Map<String, dynamic>>
                  int slotsOnDay = slots.where((slot) {
                    final start = DateTime.parse(slot['start_time']).toLocal(); // Ensure local time check
                    return isSameDay(start, day);
                  }).length;
                  
                  // If 8 or more slots (full day 9-5), disable
                  // This assumes simplified 1 hour slots max 8 per day.
                  // Real world would check total duration.
                  if (slotsOnDay >= 8) {
                    return false;
                  }
                  
                  return day.weekday != DateTime.saturday && day.weekday != DateTime.sunday; 
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Failed to load slots: $e')),
          ),
        ],
      ),
    );
  }
}
