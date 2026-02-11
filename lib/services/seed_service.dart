import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    try {
      if (kDebugMode) print('Clearing existing data...');
      await _clearCollection('users');
      await _clearCollection('classes');
      await _clearCollection('subjects');
      await _clearCollection('timetable');
      await _clearCollection('attendance');
      await _clearCollection('attendance_sessions');
      await _clearCollection('exams');

      WriteBatch batch = _db.batch();

      // --- 1. TEACHER ---
      String teacherId = 'teacher_123';
      batch.set(_db.collection('users').doc(teacherId), {
        'uid': teacherId,
        'fullName': 'Prof. John Anderson',
        'email': 'demo@routeminds.app',
        'role': 'teacher',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // --- 2. CLASSES ---
      List<String> classIds = [];
      List<String> classNames = ['10-A', '10-B'];
      for (var name in classNames) {
        DocumentReference ref = _db.collection('classes').doc();
        classIds.add(ref.id);
        batch.set(ref, {
          'name': 'Grade 10',
          'section': name.split('-')[1],
          'academicYear': '2025-2026',
          'teacherId': teacherId,
          'studentCount': 25,
        });
      }

      // --- 3. SUBJECTS & CHAPTERS ---
      List<Map<String, dynamic>> subjectsData = [
        {'name': 'Mathematics', 'color': '#0f68e6', 'icon': 'math'},
        {'name': 'Physics', 'color': '#10b981', 'icon': 'science'},
        {'name': 'Chemistry', 'color': '#f59e0b', 'icon': 'science'},
        {'name': 'English', 'color': '#8b5cf6', 'icon': 'book'},
        {'name': 'History', 'color': '#ef4444', 'icon': 'history'},
      ];

      List<String> subjectIds = [];
      for (var s in subjectsData) {
        DocumentReference ref = _db.collection('subjects').doc();
        subjectIds.add(ref.id);
        batch.set(ref, {
          'name': s['name'],
          'slug': s['name'].toString().toLowerCase(),
          'classIds': classIds,
          'colorHex': s['color'],
          'iconUrl': 'assets/icons/${s['icon']}.png',
        });

        // Chapters
        for (int i = 1; i <= 4; i++) {
          DocumentReference cRef = ref.collection('chapters').doc();
          batch.set(cRef, {
            'title': 'Chapter $i: Introduction to ${s['name']}',
            'slug': 'chapter-$i',
            'description': 'Foundational concepts of ${s['name']}.',
            'subjectId': ref.id,
            'isPublished': true,
          });
        }
      }

      // --- 4. STUDENTS ---
      List<String> firstNames = [
        'James',
        'Mary',
        'Robert',
        'Patricia',
        'John',
        'Jennifer',
        'Michael',
        'Linda',
        'David',
        'Elizabeth',
        'William',
        'Barbara',
        'Richard',
        'Susan',
        'Joseph',
        'Jessica',
        'Thomas',
        'Sarah',
        'Charles',
        'Karen',
        'Christopher',
        'Nancy',
        'Daniel',
        'Lisa',
        'Matthew',
        'Betty',
        'Anthony',
        'Margaret',
        'Mark',
        'Sandra',
        'Donald',
        'Ashley',
      ];
      List<String> lastNames = [
        'Smith',
        'Johnson',
        'Williams',
        'Brown',
        'Jones',
        'Garcia',
        'Miller',
        'Davis',
        'Rodriguez',
        'Martinez',
        'Hernandez',
        'Lopez',
        'Gonzalez',
        'Wilson',
        'Anderson',
      ];

      List<String> allStudentIds = [];
      for (int i = 0; i < 50; i++) {
        String studentId = 'student_demo_${(i + 1).toString().padLeft(3, '0')}';
        allStudentIds.add(studentId);
        String classId = classIds[i < 25 ? 0 : 1];
        String section = classNames[i < 25 ? 0 : 1].split('-')[1];
        String fName = firstNames[i % firstNames.length];
        String lName = lastNames[i % lastNames.length];

        batch.set(_db.collection('users').doc(studentId), {
          'uid': studentId,
          'fullName': '$fName $lName',
          'email':
              '${fName.toLowerCase()}.${lName.toLowerCase()}${i + 1}@demo.com',
          'role': 'student',
          'classId': classId,
          'className': 'Grade 10',
          'section': section,
          'rollNumber': 'R-${(i + 1).toString().padLeft(3, '0')}',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Alexandira Rivers (student_123) for Demo Student button
        if (i == 0) {
          batch.set(_db.collection('users').doc('student_123'), {
            'uid': 'student_123',
            'fullName': '$fName $lName',
            'email': 'alexandria@routeminds.app',
            'role': 'student',
            'classId': classId,
            'className': 'Grade 10',
            'section': section,
            'rollNumber': 'R-001',
            'createdAt': FieldValue.serverTimestamp(),
          });
          allStudentIds.add('student_123');
        }
      }

      await batch.commit();
      batch = _db.batch();

      // --- 5. TIMETABLE ---
      List<String> days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
      ];
      for (var classId in classIds) {
        String section = classId == classIds[0] ? 'A' : 'B';
        for (int d = 0; d < days.length; d++) {
          // 3 periods per day
          for (int p = 0; p < 3; p++) {
            int subIdx = (d + p) % subjectIds.length;
            batch.set(_db.collection('timetable').doc(), {
              'classId': classId,
              'className': 'Grade 10',
              'subjectName': subjectsData[subIdx]['name'],
              'subjectId': subjectIds[subIdx],
              'teacherId': teacherId,
              'dayOfWeek': days[d],
              'startTime': '${08 + p}:00:00',
              'endTime': '${09 + p}:00:00',
              'room': 'Room 10$section',
              'section': section,
              'studentCount': 25,
            });
          }
        }
      }

      // --- 6. ATTENDANCE (7 days + Today) ---
      DateTime today = DateTime(2026, 2, 11);
      for (int i = 0; i < 8; i++) {
        DateTime date = today.subtract(Duration(days: i));
        if (date.weekday > 5) continue; // Skip weekends

        for (var classId in classIds) {
          String section = classId == classIds[0] ? 'A' : 'B';
          DocumentReference sessionRef = _db
              .collection('attendance_sessions')
              .doc();
          batch.set(sessionRef, {
            'classId': classId,
            'className': 'Grade 10',
            'section': section,
            'subjectId': subjectIds[0], // Mocking attendance for first subject
            'subjectName': subjectsData[0]['name'],
            'teacherId': teacherId,
            'date': Timestamp.fromDate(date),
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Just a simple loop for few records to avoid 500 limit too fast
          for (int s = 0; s < 5; s++) {
            // Seeding first 5 students per session for performance
            String sid = i < 25 ? allStudentIds[s] : allStudentIds[s + 25];
            String studentName =
                '${firstNames[s % firstNames.length]} ${lastNames[s % lastNames.length]}';

            batch.set(_db.collection('attendance').doc(), {
              'studentId': sid,
              'studentName': studentName,
              'classId': classId,
              'className': 'Grade 10',
              'section': section,
              'subjectId': subjectIds[0],
              'subjectName': subjectsData[0]['name'],
              'teacherId': teacherId,
              'date': Timestamp.fromDate(date),
              'status': s % 5 == 0 ? 'Absent' : 'Present',
              'remarks': '',
              'sessionId': sessionRef.id,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
        await batch.commit();
        batch = _db.batch();
      }

      // --- 7. EXAMS & ANALYTICS ---
      for (int s = 0; s < subjectIds.length; s++) {
        for (int e = 1; e <= 2; e++) {
          // 2 exams per subject
          DocumentReference examRef = _db.collection('exams').doc();
          batch.set(examRef, {
            'title': '${subjectsData[s]['name']} Quiz $e',
            'subjectId': subjectIds[s],
            'subjectName': subjectsData[s]['name'],
            'classId': classIds[0],
            'teacherId': teacherId,
            'date': Timestamp.fromDate(today.subtract(const Duration(days: 5))),
            'totalMarks': 100,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Submissions for first class
          for (int studentIdx = 0; studentIdx < 5; studentIdx++) {
            String sid = allStudentIds[studentIdx];
            batch.set(examRef.collection('submissions').doc(sid), {
              'studentId': sid,
              'studentName':
                  '${firstNames[studentIdx % firstNames.length]} ${lastNames[studentIdx % lastNames.length]}',
              'marksObtained': 70 + (studentIdx * 5) % 30,
              'totalMarks': 100,
              'subjectId': subjectIds[s],
              'subjectName': subjectsData[s]['name'],
              'submittedAt': FieldValue.serverTimestamp(),
            });
          }
          await batch.commit();
          batch = _db.batch();
        }
      }

      if (kDebugMode) print('Database Seeded Successfully with Real Data!');
    } catch (e) {
      if (kDebugMode) print('Error seeding database: $e');
      rethrow;
    }
  }

  Future<void> _clearCollection(String collectionPath) async {
    // Simple batch delete
    QuerySnapshot snapshot = await _db.collection(collectionPath).get();
    if (snapshot.docs.isNotEmpty) {
      WriteBatch batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
