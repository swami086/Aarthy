import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import 'package:safe_space_app/utils/constants/app_colors.dart';

class TimeSlotSelectionScreen extends ConsumerStatefulWidget {
  final String mentorId;
  final DateTime selectedDate;

  const TimeSlotSelectionScreen({
    super.key, 
    required this.mentorId, 
    required this.selectedDate
  });

  @override
  ConsumerState<TimeSlotSelectionScreen> createState() => _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState extends ConsumerState<TimeSlotSelectionScreen> {
  // Hardcoded 9-5 slots for MVP
  // Ideally fetched from mentor settings
  final List<int> _hours = [9, 10, 11, 12, 13, 14, 15, 16, 17];
  Map<int, bool> _availabilityCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAllSlots();
  }

  Future<void> _checkAllSlots() async {
    final service = ref.read(appointmentServiceProvider);
    
    final futures = _hours.map((h) async {
      final start = DateTime(
        widget.selectedDate.year, 
        widget.selectedDate.month, 
        widget.selectedDate.day, 
        h, 0
      );
      final end = start.add(const Duration(minutes: 60)); 
      
      final isAvailable = await service.checkAvailability(widget.mentorId, start, end);
      return MapEntry(h, isAvailable);
    });

    final results = await Future.wait(futures);
    _availabilityCache = Map.fromEntries(results);

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(DateFormat('MMM d').format(widget.selectedDate))),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "Select a time slot", 
                style: Theme.of(context).textTheme.titleLarge
              ),
              const SizedBox(height: 16),
              ..._hours.map((h) {
                final isAvailable = _availabilityCache[h] ?? false;
                // Use a valid dummy date for time formatting
                final timeLabel = DateFormat('h:mm a').format(DateTime(2000, 1, 1, h));
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ElevatedButton(
                    onPressed: isAvailable ? () {
                       final start = DateTime(
                          widget.selectedDate.year, 
                          widget.selectedDate.month, 
                          widget.selectedDate.day, 
                          h, 0
                       );
                       final end = start.add(const Duration(minutes: 60));
                       
                       context.push(
                         '/book-appointment/${widget.mentorId}/confirm',
                         extra: {
                           'startTime': start,
                           'endTime': end,
                         }
                       );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvailable ? AppColors.primary : Colors.grey[200],
                      foregroundColor: isAvailable ? Colors.white : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(timeLabel, style: const TextStyle(fontSize: 16)),
                        if (!isAvailable) const Text("(Booked)"),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
    );
  }
}
