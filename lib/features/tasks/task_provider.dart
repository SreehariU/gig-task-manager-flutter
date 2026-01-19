import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/task_model.dart';
import 'task_service.dart';

/// Provides TaskService
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

/// Stream of tasks for the logged-in user
final taskListProvider = StreamProvider<List<TaskModel>>((ref) {
  return ref.read(taskServiceProvider).getTasks();
});
