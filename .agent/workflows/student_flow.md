---
description: Journey and logic of the Student user in RouteMinds
---

# Student User Flow

This workflow documents the student journey within RouteMinds, covering authentication, dashboard interaction, and academic management.

## 1. Authentication & Enrollment

- **Login**: Student enters email/password.
- **Role Verification**: `AuthWrapper` and `LoginScreen` check Firestore `users/{uid}/role == 'student'`.
- **Enrollment**: Students must have a `classId` in their profile to see academic data.
  - _Condition_: If `classId` is missing, screens like Dashboard and Timetable display a "Not enrolled" state.
- **Offline Access**: If previously logged in, students can use the PIN (default `1234`) to access the app without internet via `AuthService` cache.

## 2. Student Dashboard

- **Real-time Sync**: `ConnectivityIndicator` wraps the dashboard.
- **Attendance Card**: Real-time percentage calculation from `attendance` collection.
  - _Logic_: `(Present sessions / Total sessions) * 100`.
- **Upcoming Lecture**: Fetches today's timetable filtered by `classId` and `dayOfWeek`.
  - _Success State_: Shows the next class starting after the current time.
  - _Empty State_: Card is hidden if no more classes today.
- **Quick Links**:
  - `Attendance`: Opens Detailed Attendance History.
  - `View Timetable`: Opens Weekly Schedule.

## 3. Academic Content

### Enrolled Courses

- Fetches all documents from `subjects` collection where `classIds` array contains current student's `classId`.
- Searchable list of subjects with progress indicators (currently progress is UI-only).

### Weekly Timetable

- Filtered by `classId` and selected `day`.
- **Live Indicator**: If current server/system time is between `startTime` and `endTime`, the class is marked as **LIVE NOW**.
- **Completed State**: If current time is past `endTime`, class is marked as **Completed**.

## 4. Learning Analytics

- **GPA Calculation**:
  - Fetches `submissions` subcollection (using `collectionGroup`) for the `studentId`.
  - Formula: `Average of (marksObtained / totalMarks) * 4.0`.
- **Attendance Correlation**: Compares subject-wise attendance with subject-wise exam scores.
- **Achievements**: Static or logic-based badges (e.g., "Top 5% in Mathematics") based on relative performance in `submissions`.

## 5. Data Flow & Persistence

- **Firestore Collections**:
  - `users`: Profile data, `classId`.
  - `attendance`: Flat records for student performance.
  - `exams/submissions`: Sub-collection for results.
  - `timetable`: Schedule data.
  - `subjects`: Metadata for courses.
- **Offline Sync**: All data fetched via `StreamBuilder` is cached by Firestore's persistence layer. UI displays "Ready for offline usage" when connectivity is lost.
