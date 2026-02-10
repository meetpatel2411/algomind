import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    try {
      if (kDebugMode) print('Clearing existing data...');
      await _clearCollection('users');
      await _clearCollection('classes');
      await _clearCollection('subjects');
      await _clearCollection('timetable');
      // Note: chapters are subcollections, will be cleared when parent subjects are deleted or need specific handling if top-level.
      // Since we clear subjects, if chapters are subcollections, they are "orphan" but reachable?
      // Firestore subcollections strictly speaking persist but are hard to find without parent.
      // Ideally we should recursively delete, but for seeding purpose, just creating new is fine as distinct IDs.

      WriteBatch batch = _db.batch();

      // --- 1. USERS ---

      // Teacher: Mr. Smith
      String teacherId;
      String email = 'smith@routeminds.app';
      String password = 'password123';

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.email == email) {
        teacherId = currentUser.uid;
      } else {
        try {
          UserCredential cred = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          teacherId = cred.user!.uid;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
            UserCredential cred = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
            teacherId = cred.user!.uid;
          } else {
            rethrow;
          }
        }
      }

      DocumentReference teacherRef = _db.collection('users').doc(teacherId);
      batch.set(teacherRef, {
        'uid': teacherId,
        'fullName': 'Mr. Smith',
        'username': 'mr_smith',
        'email': email,
        'role': 'teacher',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // --- 2. CLASSES ---

      // Grade 12-A
      DocumentReference class12ARef = _db.collection('classes').doc();
      String class12AId = class12ARef.id;
      batch.set(class12ARef, {
        'name': 'Grade 12',
        'section': 'A',
        'academicYear': '2023-2024',
        'teacherId': teacherId,
        'studentCount': 2, // Initial count
      });

      // Grade 11-B
      DocumentReference class11BRef = _db.collection('classes').doc();
      String class11BId = class11BRef.id;
      batch.set(class11BRef, {
        'name': 'Grade 11',
        'section': 'B',
        'academicYear': '2023-2024',
        'teacherId': teacherId,
        'studentCount': 0,
      });

      // --- 3. STUDENTS ---

      // Alexandria Rivers (Student G12-A)
      DocumentReference studentAlexRef = _db.collection('users').doc();
      // Ideally we create Auth for students too, but for demo we can just create Firestore entries
      // or if "Demo Student" button uses a fixed ID, we should use that.
      // Checking previously set "fixed ID" logic (student_123).
      // I'll set Alexandria as 'student_123' so the Demo Login works.

      String alexId = 'student_123';
      studentAlexRef = _db.collection('users').doc(alexId);

      batch.set(studentAlexRef, {
        'uid': alexId,
        'fullName': 'Alexandria Rivers',
        'username': 'alexandria',
        'email': 'alexandria@routeminds.app',
        'role': 'student',
        'classId': class12AId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Marcus Sterling (Student G12-A)
      DocumentReference studentMarcusRef = _db.collection('users').doc();
      batch.set(studentMarcusRef, {
        'uid': studentMarcusRef.id,
        'fullName': 'Marcus Sterling',
        'username': 'marcus',
        'email': 'marcus@routeminds.app',
        'role': 'student',
        'classId': class12AId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // --- 4. SUBJECTS ---

      // Advanced Physics (Grade 12-A)
      DocumentReference physRef = _db.collection('subjects').doc();
      String physId = physRef.id;
      batch.set(physRef, {
        'name': 'Advanced Physics',
        'slug': 'adv-physics-12',
        'classIds': [class12AId],
        'iconUrl': 'assets/icons/physics.png',
        'colorHex': '#0f68e6',
      });

      // Calculus II (Grade 12-A)
      DocumentReference calcRef = _db.collection('subjects').doc();
      batch.set(calcRef, {
        'name': 'Calculus II',
        'slug': 'calculus-ii-12',
        'classIds': [class12AId],
        'iconUrl': 'assets/icons/math.png',
        'colorHex': '#ea580c',
      });

      // --- 5. CHAPTERS ---

      // Thermodynamics (Physics)
      DocumentReference thermoRef = physRef.collection('chapters').doc();
      batch.set(thermoRef, {
        'title': 'Thermodynamics',
        'slug': 'thermodynamics',
        'description': 'Study of heat and energy.',
        'subjectId': physId,
        'isPublished': true,
      });

      // Quantum Mechanics (Physics)
      DocumentReference quantumRef = physRef.collection('chapters').doc();
      batch.set(quantumRef, {
        'title': 'Quantum Mechanics',
        'slug': 'quantum-mechanics',
        'description': 'Intro to quantum physics.',
        'subjectId': physId,
        'isPublished': true,
      });

      // --- 6. TIMETABLE ---

      // Monday 09:00 - 10:30 (Physics, Room 402)
      DocumentReference tt1Ref = _db.collection('timetable').doc();
      batch.set(tt1Ref, {
        'classId': class12AId,
        'className': 'Grade 12',
        'subjectName': 'Advanced Physics',
        'subjectId': physId,
        'teacherId': teacherId,
        'dayOfWeek': 'Monday',
        'startTime': '09:00:00',
        'endTime': '10:30:00',
        'room': 'Room 402',
        'section': 'A',
        'studentCount': 2,
      });

      // Wednesday 11:00 - 12:30 (Physics, Lab B)
      DocumentReference tt2Ref = _db.collection('timetable').doc();
      batch.set(tt2Ref, {
        'classId': class12AId,
        'className': 'Grade 12',
        'subjectName': 'Advanced Physics',
        'subjectId': physId,
        'teacherId': teacherId,
        'dayOfWeek': 'Wednesday',
        'startTime': '11:00:00',
        'endTime': '12:30:00',
        'room': 'Lab B',
        'section': 'A',
        'studentCount': 2,
      });

      await batch.commit();
      batch = _db.batch(); // Re-initialize for the next section

      // --- 7. DEMO TEACHER (teacher_123) SYSTEMATIC SEEDING ---
      // This will create a realistic school environment for the demo teacher.

      String demoTeacherId = 'teacher_123';

      // Demo Teacher Profile
      batch.set(_db.collection('users').doc(demoTeacherId), {
        'uid': demoTeacherId,
        'fullName': 'Prof. John Anderson',
        'email': 'demo@routeminds.app',
        'role': 'teacher',
        'createdAt': FieldValue.serverTimestamp(),
      });

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
        'Thomas',
        'Taylor',
        'Moore',
        'Jackson',
        'Martin',
        'Lee',
        'Perez',
        'Thompson',
        'White',
      ];
      List<String> subjectsList = [
        'Mathematics',
        'English',
        'Science',
        'History',
        'Geography',
        'Art',
        'Music',
        'Physical Education',
        'Computer Science',
      ];
      List<String> days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
      ];
      List<Map<String, String>> slots = [
        {'start': '08:00:00', 'end': '09:00:00'},
        {'start': '09:15:00', 'end': '10:15:00'},
        {'start': '10:30:00', 'end': '11:45:00'},
        {'start': '12:30:00', 'end': '01:30:00'},
        {'start': '01:45:00', 'end': '02:45:00'},
      ];

      int studentCounter = 1;
      int globalBatchCount = 0;

      // Create Grades 1 to 10
      for (int grade = 1; grade <= 10; grade++) {
        // Sections A, B, C for each grade
        for (String section in ['A', 'B', 'C']) {
          DocumentReference classRef = _db.collection('classes').doc();
          String classId = classRef.id;
          String className = '$grade';

          int studentsInThisClass = 10 + (studentCounter % 6); // 10-15 students

          batch.set(classRef, {
            'name': className,
            'section': section,
            'academicYear': '2023-2024',
            'teacherId': demoTeacherId,
            'studentCount': studentsInThisClass,
          });

          // Create Students for this class
          for (int s = 0; s < studentsInThisClass; s++) {
            String fName = firstNames[(studentCounter + s) % firstNames.length];
            String lName =
                lastNames[(studentCounter * s + s) % lastNames.length];
            String fullName = '$fName $lName';
            String studentId =
                'student_demo_${studentCounter.toString().padLeft(3, '0')}';

            DocumentReference studentRef = _db
                .collection('users')
                .doc(studentId);
            batch.set(studentRef, {
              'uid': studentId,
              'fullName': fullName,
              'email': '${fName.toLowerCase()}${studentCounter}@demo.com',
              'role': 'student',
              'classId': classId,
              'className': className,
              'section': section,
              'rollNumber': 'R-${studentCounter.toString().padLeft(3, '0')}',
              'createdAt': FieldValue.serverTimestamp(),
            });
            studentCounter++;
          }

          // Create Timetable entries (2-3 per class per week)
          for (int d = 0; d < 2; d++) {
            String day =
                days[(grade +
                        (section == 'A'
                            ? 0
                            : section == 'B'
                            ? 1
                            : 2) +
                        d) %
                    days.length];
            var slot = slots[(grade + d) % slots.length];
            String subject = subjectsList[(grade + d) % subjectsList.length];

            DocumentReference ttRef = _db.collection('timetable').doc();
            batch.set(ttRef, {
              'classId': classId,
              'className': className,
              'subjectName': subject,
              'subjectId': 'sub_${subject.toLowerCase().replaceAll(' ', '_')}',
              'teacherId': demoTeacherId,
              'dayOfWeek': day,
              'startTime': slot['start'],
              'endTime': slot['end'],
              'room': 'Room ${grade}${section}${d + 1}',
              'section': section,
              'studentCount': studentsInThisClass,
            });
          }

          globalBatchCount++;
          // Firestore batch limit is 500 operations. We are doing ~15 per class.
          // 30 classes * 15 = 450. We are close. Let's commit every 10 classes.
          if (globalBatchCount % 10 == 0) {
            await batch.commit();
            batch = _db.batch();
          }
        }
      }

      // Check if there are any remaining operations to commit
      if (globalBatchCount % 10 != 0) {
        await batch.commit();
      }

      if (kDebugMode)
        print('Database Seeded Successfully with Extended Real-World Data!');
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
