import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/task_model.dart';

class TaskService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _taskCollection() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks');
  }

  Stream<List<TaskModel>> getTasks() {
    return _taskCollection()
        .orderBy('dueDate')
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map(TaskModel.fromFirestore).toList(),
    );
  }

  Future<void> addTask(TaskModel task) async {
    await _taskCollection().add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskCollection().doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _taskCollection().doc(taskId).delete();
  }

  Future<void> toggleComplete(TaskModel task) async {
    await _taskCollection().doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }
}
