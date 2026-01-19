import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });

  // 🔁 Firestore → App
  factory TaskModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return TaskModel(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      priority: TaskPriority.values.firstWhere(
            (e) => e.name == data['priority'],
      ),
      isCompleted: data['isCompleted'],
    );
  }

  // 🔁 App → Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority.name,
      'isCompleted': isCompleted,
    };
  }
}
