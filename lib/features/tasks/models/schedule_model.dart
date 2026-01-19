import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String place;
  final String notes;
  final bool createTask;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.place,
    required this.notes,
    required this.createTask,
  });

  factory ScheduleModel.fromJson(String id, Map<String, dynamic> json) {
    return ScheduleModel(
      id: id,
      title: json['title'] as String,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      place: json['place'] as String,
      notes: json['notes'] as String,
      createTask: json['createTask'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'place': place,
      'notes': notes,
      'createTask': createTask,
    };
  }
}
