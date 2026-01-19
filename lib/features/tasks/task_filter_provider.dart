import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/task_model.dart';

enum TaskStatusFilter { all, completed, incomplete }

class TaskFilterState {
  final TaskPriority? priority;
  final TaskStatusFilter status;

  const TaskFilterState({
    this.priority,
    this.status = TaskStatusFilter.all,
  });

  TaskFilterState copyWith({
    TaskPriority? priority,
    TaskStatusFilter? status,
  }) {
    return TaskFilterState(
      priority: priority,
      status: status ?? this.status,
    );
  }
}

final taskFilterProvider =
StateProvider<TaskFilterState>((ref) => const TaskFilterState());
