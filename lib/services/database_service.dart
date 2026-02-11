import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get users => _db.collection('users');
  CollectionReference get classes => _db.collection('classes');
  CollectionReference get subjects => _db.collection('subjects');
  CollectionReference get exams => _db.collection('exams');
  CollectionReference get timetable => _db.collection('timetable');
  CollectionReference get attendanceSessions =>
      _db.collection('attendance_sessions');
  CollectionReference get attendance =>
      _db.collection('attendance'); // New flat table
  CollectionReference get examSubmissions =>
      _db.collection('exam_submissions'); // New flat table for analytics
  CollectionReference get notifications => _db.collection('notifications');

  // --- USER METHODS ---

  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    try {
      await users.doc(uid).set(userData);
    } catch (e) {
      if (kDebugMode) print('Error creating user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await users.doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) print('Error getting user profile: $e');
      return null;
    }
  }

  Stream<QuerySnapshot> getStudents() {
    return users.where('role', isEqualTo: 'student').snapshots();
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).update(data);
  }

  Stream<QuerySnapshot> getStudentsByClass(String classId) {
    return users
        .where('role', isEqualTo: 'student')
        .where('classId', isEqualTo: classId)
        .snapshots();
  }

  Stream<QuerySnapshot> getStudentsByClassNameAndSection(
    String className,
    String section,
  ) {
    return users
        .where('role', isEqualTo: 'student')
        .where('className', isEqualTo: className)
        .where('section', isEqualTo: section)
        .snapshots();
  }

  Stream<int> getAllStudentsCount() {
    return users
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // --- STUDENT CRUD ---

  Future<void> addStudent(Map<String, dynamic> data) async {
    // Generate a new ID if not provided, or use Auth UID if available (handling that in UI/Auth service)
    // For simple management here, we might just create a Firestore doc.
    // Ideally, we create an Auth user too, but that requires Admin SDK or Cloud Functions usually.
    // For this prototype, we'll just add to Firestore.
    DocumentReference ref = users.doc();
    await ref.set({
      ...data,
      'uid': ref.id,
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStudent(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).update(data);
  }

  Future<void> deleteStudent(String uid) async {
    await users.doc(uid).delete();
  }

  // --- ACADEMIC METHODS ---

  Stream<QuerySnapshot> getTeacherClasses(String teacherId) {
    return classes.where('teacherId', isEqualTo: teacherId).snapshots();
  }

  Stream<QuerySnapshot> getStudentClasses(String classId) {
    return classes.where(FieldPath.documentId, isEqualTo: classId).snapshots();
  }

  Stream<QuerySnapshot> getSubjects(String? classId) {
    if (classId == null) return subjects.snapshots();
    return subjects.where('classIds', arrayContains: classId).snapshots();
  }

  // Get classes for specific date (filters by day of week)
  Stream<QuerySnapshot> getTeacherClassesByDate(
    String teacherId,
    DateTime date,
  ) {
    final dayOfWeek = _getDayName(date);
    return timetable
        .where('teacherId', isEqualTo: teacherId)
        .where('dayOfWeek', isEqualTo: dayOfWeek)
        .snapshots();
  }

  // Get schedule for a student (class) for specific date
  Stream<QuerySnapshot> getStudentSchedule(String classId, DateTime date) {
    final dayOfWeek = _getDayName(date);
    return timetable
        .where('classId', isEqualTo: classId)
        .where('dayOfWeek', isEqualTo: dayOfWeek)
        .snapshots();
  }

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  // Get attendance history for a teacher
  Stream<QuerySnapshot> getAttendanceHistory(String teacherId) {
    return attendanceSessions
        .where('teacherId', isEqualTo: teacherId)
        // .orderBy('date', descending: true) // Temporarily removed to bypass index requirement
        // .limit(50)
        .snapshots();
  }

  // --- ATTENDANCE METHODS ---

  Future<void> markAttendance(
    String classId,
    String subjectId,
    String teacherId,
    DateTime date,
    List<Map<String, dynamic>> records,
  ) async {
    WriteBatch batch = _db.batch();

    // 1. Create Session Document (Meta-data for History)
    DocumentReference sessionRef = attendanceSessions.doc();
    batch.set(sessionRef, {
      'classId': classId,
      'className': records.isNotEmpty ? records[0]['className'] : '',
      'section': records.isNotEmpty ? records[0]['section'] : '',
      'subjectId': subjectId,
      'subjectName': records.isNotEmpty ? records[0]['subjectName'] : '',
      'teacherId': teacherId,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Add Flat Records to 'attendance' table
    for (var record in records) {
      // Individual record for management/search
      DocumentReference flatRef = attendance.doc();
      batch.set(flatRef, {
        'studentId': record['studentId'],
        'studentName': record['studentName'],
        'classId': classId,
        'className': record['className'],
        'section': record['section'],
        'subjectId': subjectId,
        'subjectName': record['subjectName'],
        'teacherId': teacherId,
        'date': Timestamp.fromDate(date),
        'status': record['status'], // 'Present', 'Absent', 'Late'
        'remarks': record['remarks'] ?? '',
        'sessionId': sessionRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Also keep nested record for direct session view if needed
      DocumentReference recordRef = sessionRef
          .collection('records')
          .doc(record['studentId']);
      batch.set(recordRef, {
        'studentId': record['studentId'],
        'status': record['status'],
        'remarks': record['remarks'] ?? '',
      });
    }

    await batch.commit();
  }

  // Management: Get attendance for a specific student
  Stream<QuerySnapshot> getStudentAttendanceHistory(String studentId) {
    return attendance
        .where('studentId', isEqualTo: studentId)
        // .orderBy('date', descending: true)
        .snapshots();
  }

  // Management: Get attendance for a class on a specific date
  Stream<QuerySnapshot> getAttendanceByClassAndDate(
    String classId,
    DateTime date,
  ) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return attendance
        .where('classId', isEqualTo: classId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots();
  }

  // --- EXAM METHODS ---

  Stream<QuerySnapshot> getExams() {
    return exams
        .snapshots(); // .orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> createExam(
    Map<String, dynamic> examData,
    List<Map<String, dynamic>> questions,
  ) async {
    WriteBatch batch = _db.batch();

    // 1. Create Exam Document
    DocumentReference examRef = exams.doc();
    batch.set(examRef, {
      ...examData,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Add Questions
    for (var q in questions) {
      DocumentReference qRef = examRef.collection('questions').doc();
      batch.set(qRef, q);
    }

    await batch.commit();
  }

  // Get exams for a specific class (Student View)

  Stream<QuerySnapshot> getExamsForClass(String classId) {
    return exams
        .where('classId', isEqualTo: classId)
        // .orderBy('date', descending: true)
        .snapshots();
  }

  // Get all exams for a teacher (Teacher View)
  // Get all exams for a teacher (Teacher View)
  Stream<QuerySnapshot> getTeacherExams(String teacherId) {
    return exams
        .where('teacherId', isEqualTo: teacherId)
        // .orderBy('date', descending: true)
        .snapshots();
  }

  // Get results for a specific exam (Teacher View)
  Stream<QuerySnapshot> getExamResults(String examId) {
    return examSubmissions.where('examId', isEqualTo: examId).snapshots();
  }

  // Get all exam results for a student (Analytics)
  // Note: This requires a collectionGroup index if 'submissions' is a subcollection of exams
  // OR we can query exams where classId == studentClassId and then fetch their individual submission
  // A better structure for querying "all my results" might be to duplicate the result to a top-level 'results' collection
  // or 'users/{uid}/results'.
  // For now, let's use a Collection Group query which is powerful.
  Stream<QuerySnapshot> getStudentExamResults(String studentId) {
    return examSubmissions
        .where('studentId', isEqualTo: studentId)
        // .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  Future<void> submitExamResults(
    String examId,
    List<Map<String, dynamic>> results,
  ) async {
    WriteBatch batch = _db.batch();

    for (var result in results) {
      DocumentReference ref = examSubmissions.doc(); // Use top-level collection

      batch.set(ref, {
        ...result,
        'examId': examId, // Explicitly link to exam
        'submittedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // --- TEACHER STATS & UTILS ---

  // Get total students across all classes taught by teacher
  Stream<int> getTeacherStudentCount(String teacherId) {
    return classes.where('teacherId', isEqualTo: teacherId).snapshots().map((
      snapshot,
    ) {
      int total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['studentCount'] as num? ?? 0).toInt();
      }
      return total;
    });
  }

  // Get active exams count
  Stream<int> getActiveExamsCount(String teacherId) {
    return exams
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get count of ungraded exams (Pending Eval)
  // An exam is "ungraded" if it has passed its date but has no submissions?
  // Or simpler: Just count exams locally that are in the past.
  // For now, let's just count *all* exams for the teacher as "Active".
  // And for "Pending Eval", let's count exams that are completed (date < now).
  // This is a rough proxy but works for the prototype.
  Stream<int> getPendingEvaluationsCount(String teacherId) {
    return exams
        .where('teacherId', isEqualTo: teacherId)
        .where('date', isLessThan: Timestamp.now())
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Check if teacher has any classes (for auto-seed check)
  Future<bool> checkTeacherHasClasses(String teacherId) async {
    final snapshot = await classes
        .where('teacherId', isEqualTo: teacherId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // Fix: Recalculate student counts for accuracy
  Future<void> recalculateStudentCounts(String teacherId) async {
    final classSnapshot = await classes
        .where('teacherId', isEqualTo: teacherId)
        .get();
    WriteBatch batch = _db.batch();

    for (var classDoc in classSnapshot.docs) {
      final studentSnapshot = await users
          .where('classId', isEqualTo: classDoc.id)
          .where('role', isEqualTo: 'student')
          .count()
          .get();

      batch.update(classDoc.reference, {'studentCount': studentSnapshot.count});
    }

    await batch.commit();
  }

  // --- CLASS MANAGEMENT METHODS ---

  /// Create a new class/lecture
  Future<String> createClass({
    required String teacherId,
    required String name,
    required String subject,
    required String section,
    required String room,
    required String startTime,
    required String endTime,
    required String dayOfWeek,
    required int studentCount,
  }) async {
    try {
      final docRef = await classes.add({
        'teacherId': teacherId,
        'name': name,
        'subject': subject,
        'section': section,
        'room': room,
        'startTime': startTime,
        'endTime': endTime,
        'dayOfWeek': dayOfWeek,
        'studentCount': studentCount,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      if (kDebugMode) print('Error creating class: $e');
      rethrow;
    }
  }

  /// Update an existing class
  Future<void> updateClass(String classId, Map<String, dynamic> data) async {
    try {
      await classes.doc(classId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) print('Error updating class: $e');
      rethrow;
    }
  }

  /// Delete a class
  Future<void> deleteClass(String classId) async {
    try {
      await classes.doc(classId).delete();
    } catch (e) {
      if (kDebugMode) print('Error deleting class: $e');
      rethrow;
    }
  }

  /// Get a specific class by ID
  Future<DocumentSnapshot> getClassById(String classId) async {
    try {
      return await classes.doc(classId).get();
    } catch (e) {
      if (kDebugMode) print('Error getting class: $e');
      rethrow;
    }
  }

  // --- NOTIFICATION METHODS ---

  Stream<QuerySnapshot> getNotifications(String userId) {
    return notifications
        .where('userId', isEqualTo: userId)
        // .orderBy('timestamp', descending: true) // To avoid index requirement
        .snapshots();
  }
}
