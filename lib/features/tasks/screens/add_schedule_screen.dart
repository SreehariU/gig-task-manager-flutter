import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../schedule_provider.dart';
import '../models/schedule_model.dart';

class AddScheduleScreen extends ConsumerStatefulWidget {
  final DateTime selectedDay;
  final ScheduleModel? schedule;

  const AddScheduleScreen({
    super.key,
    required this.selectedDay,
    this.schedule,
  });

  @override
  ConsumerState<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends ConsumerState<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _notesController = TextEditingController();

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _createTask = true; // ✅ Add this state variable

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _placeController.text = widget.schedule!.place;
      _notesController.text = widget.schedule!.notes;
      _startTime = TimeOfDay.fromDateTime(widget.schedule!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.schedule!.endTime);
      _createTask = widget.schedule!.createTask; // ✅ Load existing value
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      final startDateTime = _combineDateAndTime(widget.selectedDay, _startTime);
      final endDateTime = _combineDateAndTime(widget.selectedDay, _endTime);

      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
        return;
      }

      final schedule = ScheduleModel(
        id: widget.schedule?.id ?? '',
        title: _titleController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        place: _placeController.text,
        notes: _notesController.text,
        createTask: _createTask, // ✅ Add this parameter
      );

      try {
        if (widget.schedule == null) {
          await ref.read(scheduleServiceProvider).addSchedule(schedule);
        } else {
          await ref.read(scheduleServiceProvider).updateSchedule(schedule);
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving schedule: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C6FEF),
        elevation: 0,
        title: Text(
          widget.schedule == null ? 'Add Schedule' : 'Edit Schedule',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_endTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _placeController,
              decoration: const InputDecoration(
                labelText: 'Place',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // ✅ Add checkbox for createTask
            CheckboxListTile(
              title: const Text('Create task from this schedule'),
              value: _createTask,
              onChanged: (value) {
                setState(() {
                  _createTask = value ?? true;
                });
              },
              activeColor: const Color(0xFF6C6FEF),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C6FEF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.schedule == null ? 'Add Schedule' : 'Update Schedule',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}