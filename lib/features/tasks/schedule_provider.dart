import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/schedule_model.dart';
import '../auth/auth_provider.dart';

/// Firestore service for schedules
class ScheduleService {
  final FirebaseFirestore _firestore;
  final String userId;

  ScheduleService(this._firestore, this.userId);

  CollectionReference get _collection =>
      _firestore.collection('users').doc(userId).collection('schedules');

  /// ➕ Add new schedule
  Future<void> addSchedule(ScheduleModel schedule) async {
    await _collection.add(schedule.toJson());
  }

  /// ✏️ Update schedule
  Future<void> updateSchedule(ScheduleModel schedule) async {
    await _collection.doc(schedule.id).update(schedule.toJson());
  }

  /// 👀 Watch ALL schedules (optional)
  Stream<List<ScheduleModel>> watchSchedules() {
    return _collection
        .orderBy('startTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => ScheduleModel.fromJson(
          doc.id,
          doc.data() as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

  /// 📅 Watch schedules for a SPECIFIC DAY
  Stream<List<ScheduleModel>> watchSchedulesForDay(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _collection
        .where(
      'startTime',
      isGreaterThanOrEqualTo: startOfDay,
    )
        .where(
      'startTime',
      isLessThan: endOfDay,
    )
        .orderBy('startTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => ScheduleModel.fromJson(
          doc.id,
          doc.data() as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }

  /// 🗑 Delete schedule
  Future<void> deleteSchedule(String id) async {
    await _collection.doc(id).delete();
  }
}

/// Provider to expose ScheduleService
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw Exception('User not logged in');
  }

  return ScheduleService(FirebaseFirestore.instance, user.uid);
});

/// 📅 Selected day (Calendar)
final selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// 📅 Schedules for selected day
final schedulesForSelectedDayProvider =
StreamProvider<List<ScheduleModel>>((ref) {
  final day = ref.watch(selectedDayProvider);
  final service = ref.watch(scheduleServiceProvider);

  return service.watchSchedulesForDay(day);
});
