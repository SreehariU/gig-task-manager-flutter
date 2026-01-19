import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_schedule_screen.dart';
import '../schedule_provider.dart';
import '../models/schedule_model.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // 🔥 watch schedules for selected day
    final schedulesAsync =
    ref.watch(schedulesForSelectedDayProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C6FEF),
        elevation: 0,
        title: const Text(
          'Schedule',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });

              // 🔄 update provider so schedules refresh
              ref.read(selectedDayProvider.notifier).state =
                  DateTime(
                    selected.year,
                    selected.month,
                    selected.day,
                  );
            },
            calendarStyle: const CalendarStyle(

              selectedDecoration: BoxDecoration(
                color: Color(0xFF6C6FEF),
                shape: BoxShape.circle,
              ),
              defaultTextStyle:
              TextStyle(color: Colors.black87),
              weekendTextStyle:
              TextStyle(color: Colors.black87),
              outsideTextStyle:
              TextStyle(color: Colors.grey),
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle:
              TextStyle(color: Colors.black),
              leftChevronIcon:
              Icon(Icons.chevron_left),
              rightChevronIcon:
              Icon(Icons.chevron_right),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle:
              TextStyle(color: Colors.black87),
              weekendStyle:
              TextStyle(color: Colors.redAccent),
            ),
          ),

          const SizedBox(height: 16),

          // 🔽 schedules list
          Expanded(
            child: schedulesAsync.when(
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error: $e')),
              data: (schedules) {
                if (schedules.isEmpty) {
                  return const Center(
                    child: Text(
                      'No schedules for this day',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final s = schedules[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddScheduleScreen(
                              selectedDay: s.startTime,
                              schedule: s, // 👈 EDIT MODE
                            ),
                          ),
                        );
                      },
                      child: _ScheduleCard(
                        title: s.title,
                        time:
                        '${_formatTime(context, s.startTime)} - ${_formatTime(context, s.endTime)}',
                        place: s.place,
                        notes: s.notes,
                      ),
                    );

                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C6FEF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddScheduleScreen(
                selectedDay: _selectedDay,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime time) {
    return TimeOfDay.fromDateTime(time).format(context);
  }
}

class _ScheduleCard extends StatelessWidget {
  final String title;
  final String time;
  final String place;
  final String notes;

  const _ScheduleCard({
    required this.title,
    required this.time,
    required this.place,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Time: $time',
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            'Place: $place',
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            'Notes: $notes',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
