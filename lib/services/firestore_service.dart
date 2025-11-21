import 'package:attendance_app/main.dart';
import 'package:attendance_app/models/attendance_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get attendance records for user (real-time stream)
  Stream<List<AttendanceRecord>> getAttendanceRecord(String userId) {
    // firestore = utk menyimpan semuanya -> user id, check in time, dkk
    // realtime database = berkaitan dengan gambar
    return _firestore
      .collection('attendance')
      .where('user_id', isEqualTo: userId)
      .orderBy('check_in_time', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
        .map((doc) => AttendanceRecord.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
      });
  }

  // get today's attendance record (real-time screen) -> dipanggil terus
  Stream<AttendanceRecord?> getTodayRecordStream(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    return _firestore
        .collection('attendance')
        .where('user_id', isEqualTo: userId)
        .orderBy('check_in_time', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
          // filter today's record on client side
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final checkInTime = DateTime.parse(data['check_in_time'] as String);

            if (checkInTime.isAfter(startOfDay) && checkInTime.isBefore(endOfDay)) {
              // ...data -> mengambil semua data
              return AttendanceRecord.fromJson({...data, 'id': doc.id});
            }
          }
          // kalo gaada datanya
          return null;
        });
        
  }

  // get today's attendance record (one-time fetch) -> sekali doang
  Future<AttendanceRecord?> getTodayRecord(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final QuerySnapshot = await _firestore
         .collection('attendance')
         .where('user_id', isEqualTo: userId)
         .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
         .where('date', isLessThan: Timestamp.fromDate(endOfDay))
         .get();

        if (QuerySnapshot.docs.isEmpty)return null;

        return AttendanceRecord.fromJson(
          {...QuerySnapshot.docs.first.data(), 'id': QuerySnapshot.docs.first.id}
        );
  }

  Future<void> createAttendanceRecord(AttendanceRecord record) async {}

  Future<void> uploadAttendanceRecord(AttendanceRecord updateRecord) async {}


}