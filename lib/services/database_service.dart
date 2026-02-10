import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get users => _db.collection('users');
  CollectionReference get classes => _db.collection('classes');
  CollectionReference get subjects => _db.collection('subjects');
  CollectionReference get exams => _db.collection('exams');

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

  Stream<QuerySnapshot> getStudentsByClass(String classId) {
    return users
        .where('role', isEqualTo: 'student')
        .where('classId', isEqualTo: classId)
        .snapshots();
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

  // --- ATTENDANCE METHODS ---

  Future<void> markAttendance(
    String classId,
    String subjectId,
    String teacherId,
    DateTime date,
    List<Map<String, dynamic>> records,
  ) async {
    WriteBatch batch = _db.batch();

    // 1. Create Session Document
    DocumentReference sessionRef = classes
        .doc(classId)
        .collection('attendance_sessions')
        .doc();
    batch.set(sessionRef, {
      'classId': classId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Add Records
    for (var record in records) {
      DocumentReference recordRef = sessionRef
          .collection('records')
          .doc(record['studentId']);
      batch.set(recordRef, {
        'studentId': record['studentId'],
        'status': record['status'], // 'Present', 'Absent', 'Late'
        'remarks': record['remarks'] ?? '',
      });
    }

    await batch.commit();
  }

  Stream<QuerySnapshot> getAttendanceHistory(String classId) {
    return classes
        .doc(classId)
        .collection('attendance_sessions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // --- EXAM METHODS ---

  Stream<QuerySnapshot> getExams() {
    return exams.orderBy('createdAt', descending: true).snapshots();
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

  Future<void> submitExamResult(
    String examId,
    String studentId,
    Map<String, dynamic> resultData,
  ) async {
    await exams.doc(examId).collection('submissions').doc(studentId).set({
      ...resultData,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }
}
