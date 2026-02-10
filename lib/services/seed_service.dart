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
      String password = 'password123'; // Keeping consistent

      try {
        UserCredential cred = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        teacherId = cred.user!.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          UserCredential cred = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
          teacherId = cred.user!.uid;
        } else {
          rethrow;
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
        'subjectId': physId,
        'teacherId': teacherId,
        'dayOfWeek': 'Monday',
        'startTime': '09:00:00',
        'endTime': '10:30:00',
        'roomNumber': 'Room 402',
      });

      // Wednesday 11:00 - 12:30 (Physics, Lab B)
      DocumentReference tt2Ref = _db.collection('timetable').doc();
      batch.set(tt2Ref, {
        'classId': class12AId,
        'subjectId': physId,
        'teacherId': teacherId,
        'dayOfWeek': 'Wednesday',
        'startTime': '11:00:00',
        'endTime': '12:30:00',
        'roomNumber': 'Lab B',
      });

      await batch.commit();
      if (kDebugMode)
        print('Database Seeded Successfully with RouteMinds Data!');
    } catch (e) {
      if (kDebugMode) print('Error seeding database: $e');
      rethrow;
    }
  }

  Future<void> _clearCollection(String collectionPath) async {
    // Simple batch delete
    var snapshot = await _db.collection(collectionPath).get();
    WriteBatch batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
