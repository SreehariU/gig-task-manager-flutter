import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/task_model.dart';
import 'task_service.dart';

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

final taskListProvider = StreamProvider<List<TaskModel>>((ref) {
  return ref.read(taskServiceProvider).getTasks();
});
