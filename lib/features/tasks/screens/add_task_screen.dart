import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../task_provider.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final TaskModel? task;

  AddTaskScreen({super.key, this.task});


  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _dueDate = DateTime.now();
  TaskPriority _priority = TaskPriority.medium;
  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C6FEF),
        title: Text(widget.task == null ? 'Add task' : 'Edit task'),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputLabel('Title'),
              TextField(
                controller: _titleController,
                decoration: _inputDecoration('Task title'),
              ),

              const SizedBox(height: 16),

              _inputLabel('Description'),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: _inputDecoration('Task description'),
              ),

              const SizedBox(height: 16),

              _inputLabel('Due date'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                ),
                onTap: _pickDate,
              ),

              const SizedBox(height: 16),

              _inputLabel('Priority'),
              Wrap(
                spacing: 8,
                children: TaskPriority.values.map((p) {
                  final isSelected = p == _priority;
                  return ChoiceChip(
                    label: Text(p.name.toUpperCase()),
                    selected: isSelected,
                    selectedColor: _priorityColor(p).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? _priorityColor(p)
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) {
                      setState(() => _priority = p);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C6FEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save task',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- helpers ----------------

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _saveTask() async {
    if (_titleController.text.trim().isEmpty) return;

    final task = TaskModel(
      id: widget.task?.id ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      isCompleted: widget.task?.isCompleted ?? false,
    );

    final service = ref.read(taskServiceProvider);

    if (widget.task == null) {
      await service.addTask(task);
    } else {
      await service.updateTask(task);
    }

    if (mounted) Navigator.pop(context);
  }


  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF1F3F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }
}
