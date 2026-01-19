import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../task_provider.dart';
import '../models/task_model.dart';
import 'add_task_screen.dart';
import '../task_filter_provider.dart';




class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskListProvider);
    final filter = ref.watch(taskFilterProvider);


    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6C6FEF),
        title: const Text('My tasks'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.more_horiz),
          )
        ],
      ),

      body: taskAsync.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to add your first task',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var filteredTasks = tasks;

          // Priority filter
          if (filter.priority != null) {
            filteredTasks = filteredTasks
                .where((t) => t.priority == filter.priority)
                .toList();
          }

          // Status filter
          if (filter.status == TaskStatusFilter.completed) {
            filteredTasks =
                filteredTasks.where((t) => t.isCompleted).toList();
          } else if (filter.status == TaskStatusFilter.incomplete) {
            filteredTasks =
                filteredTasks.where((t) => !t.isCompleted).toList();
          }

          final today = <TaskModel>[];
          final tomorrow = <TaskModel>[];
          final thisWeek = <TaskModel>[];

          final now = DateTime.now();

          for (final task in filteredTasks) {

            final diff =
                task.dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;

            if (diff == 0) {
              today.add(task);
            } else if (diff == 1) {
              tomorrow.add(task);
            } else if (diff > 1 && diff <= 7) {
              thisWeek.add(task);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _FilterBar(),
              const SizedBox(height: 16),

              if (today.isNotEmpty)
                _TaskSection(title: 'Today', tasks: today),
              if (tomorrow.isNotEmpty)
                _TaskSection(title: 'Tomorrow', tasks: tomorrow),
              if (thisWeek.isNotEmpty)
                _TaskSection(title: 'This week', tasks: thisWeek),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C6FEF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

    );
  }
}
class _TaskSection extends ConsumerWidget {
  final String title;
  final List<TaskModel> tasks;

  const _TaskSection({
    required this.title,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),

        const SizedBox(height: 12),
        ...tasks.map(
              (task) => Dismissible(
            key: Key(task.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete task?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) {
                  ref.read(taskServiceProvider).deleteTask(task.id);
                },

                child: _TaskCard(task: task),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final TaskModel task;

  const _TaskCard({required this.task});

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTaskScreen(task: task),
          ),
        );
      },
      child: Opacity(
        opacity: task.isCompleted ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                shape: const CircleBorder(),
                onChanged: (_) {
                  ref.read(taskServiceProvider).toggleComplete(task);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _priorityColor(task.priority).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.priority.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _priorityColor(task.priority),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority filter
        Wrap(
          spacing: 8,
          children: [
            _PriorityChip(label: 'All', priority: null),
            ...TaskPriority.values.map(
                  (p) => _PriorityChip(
                label: p.name.toUpperCase(),
                priority: p,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Status filter
        Wrap(
          spacing: 8,
          children: TaskStatusFilter.values.map(
                (status) => ChoiceChip(
              label: Text(status.name.toUpperCase()),
              selected: filter.status == status,
              onSelected: (_) {
                ref.read(taskFilterProvider.notifier).state =
                    filter.copyWith(status: status);
              },
            ),
          ).toList(),
        ),
      ],
    );
  }
}

class _PriorityChip extends ConsumerWidget {
  final String label;
  final TaskPriority? priority;

  const _PriorityChip({
    required this.label,
    required this.priority,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);

    final isSelected = filter.priority == priority;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(taskFilterProvider.notifier).state =
            filter.copyWith(priority: priority);
      },
    );
  }
}

