import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'student_attendance_screen.dart';
import 'services/database_service.dart';
import 'enrolled_courses_screen.dart';
// import 'subject_selection_screen.dart';
import 'timetable_screen.dart';
import 'widgets/profile_image.dart';
import 'widgets/student_bottom_navigation.dart';
import 'notifications_screen.dart';
import 'course_details_screen.dart';
import 'learning_analytics_screen.dart';

import 'widgets/connectivity_indicator.dart';

class StudentDashboard extends StatefulWidget {
  final String? uid;
  const StudentDashboard({super.key, this.uid});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final DatabaseService _db = DatabaseService();
  late final String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
  }

  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);
  final Color warningColor = const Color(0xfff59e0b);

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDarkMode ? backgroundDark : backgroundLight;
    final Color surfaceColor = isDarkMode
        ? const Color(0xff1e293b)
        : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xff1e293b);
    final Color subTextColor = isDarkMode
        ? const Color(0xff94a3b8)
        : const Color(0xff64748b);
    final Color borderColor = isDarkMode
        ? const Color(0xff334155)
        : const Color(0xfff1f5f9);

    return Scaffold(
      backgroundColor: bgColor,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _db.getUserProfile(uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data;
          final String fullName = userData?['fullName'] ?? 'Student';
          final String classId = userData?['classId'] ?? '';

          return ConnectivityIndicator(
            child: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildHeader(
                          textColor,
                          subTextColor,
                          surfaceColor,
                          borderColor,
                          isDarkMode,
                          fullName,
                          uid,
                        ),
                        const SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              _buildAttendanceCard(
                                uid,
                                surfaceColor,
                                textColor,
                                subTextColor,
                                borderColor,
                                isDarkMode,
                              ),
                              const SizedBox(height: 12),
                              _buildQuickAccess(primaryColor),
                              const SizedBox(height: 24),

                              if (classId.isNotEmpty)
                                _buildNextClassSection(classId, primaryColor),

                              _buildSubjectSection(
                                classId,
                                textColor,
                                subTextColor,
                                primaryColor,
                                isDarkMode,
                              ),
                              const SizedBox(height: 24),
                              _buildPerformanceChart(
                                surfaceColor,
                                textColor,
                                subTextColor,
                                borderColor,
                                isDarkMode,
                              ),
                              const SizedBox(height: 24),
                              _buildOfflineSyncCard(isDarkMode, subTextColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: StudentBottomNavigation(
                      currentIndex: 0,
                      isDarkMode: isDarkMode,
                      uid: _uid,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNextClassSection(String classId, Color primaryColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getStudentSchedule(classId, DateTime.now()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now();

        List<Map<String, dynamic>> upcoming = [];
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final startStr = data['startTime'] as String?;

          if (startStr != null) {
            try {
              // Parse time like "09:00 AM" to DateTime for today
              final timeFormat = DateFormat('hh:mm a');
              final dt = timeFormat.parse(startStr);
              final classTime = DateTime(
                now.year,
                now.month,
                now.day,
                dt.hour,
                dt.minute,
              );

              if (classTime.isAfter(now)) {
                upcoming.add(data);
              }
            } catch (e) {
              // ignore parse errors
            }
          }
        }

        // Sort
        upcoming.sort((a, b) {
          try {
            final timeFormat = DateFormat('hh:mm a');
            final tA = timeFormat.parse(a['startTime']);
            final tB = timeFormat.parse(b['startTime']);
            return tA.compareTo(tB);
          } catch (e) {
            return 0;
          }
        });

        if (upcoming.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            _buildNextClassCard(upcoming.first, primaryColor),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
    bool isDarkMode,
    String userName,
    String uid,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  ProfileImage(
                    imageUrl: null,
                    size: 48,
                    borderColor: primaryColor.withValues(alpha: 0.2),
                    borderWidth: 2,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: successColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode ? backgroundDark : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $userName',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_done_rounded,
                        size: 14,
                        color: subTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Synced (Offline mode)',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationsScreen(uid: uid),
              ),
            ),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: subTextColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(
    String uid,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getStudentAttendanceHistory(uid),
      builder: (context, snapshot) {
        int total = 0;
        int present = 0;
        double percentage = 0.0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          total = docs.length;
          present = docs
              .where((d) => (d.data() as Map)['status'] == 'Present')
              .length;
          if (total > 0) {
            percentage = (present / total) * 100;
          }
        }

        final bool onTrack = percentage >= 75;
        final statusColor = onTrack ? successColor : warningColor;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL ATTENDANCE',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: subTextColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: GoogleFonts.lexend(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          onTrack ? Icons.trending_up : Icons.warning_amber,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          onTrack ? 'ON TRACK' : 'LOW ATTENDANCE',
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          value: total > 0 ? (percentage / 100) : 0,
                          strokeWidth: 6,
                          backgroundColor: isDarkMode
                              ? Colors.white10
                              : const Color(0xfff1f5f9),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$present/$total',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccess(Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentAttendanceScreen(uid: _uid),
                ),
              );
            },
            child: _buildQuickAccessButton(
              Icons.calendar_month_rounded,
              'Attendance',
              primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              // The provided instruction seems to be for a different context,
              // possibly a list of quick access items where 'index' is used.
              // Since this specific _buildQuickAccess function has two distinct
              // Expanded widgets, I will assume the instruction meant to add
              // the curly braces around the existing onTap content for the second button,
              // or that the provided code block was meant to replace the onTap content
              // of a single quick access item that uses an index.
              // Given the instruction "Add curly braces" and the provided code block
              // with 'index', it's unclear how to integrate it directly without
              // changing the structure of _buildQuickAccess.
              // I will add the curly braces around the existing Navigator.push
              // for the second Expanded widget to fulfill the "add curly braces" instruction
              // in a syntactically correct way for this specific context.
              // If the intent was to replace the onTap logic with the index-based logic,
              // the _buildQuickAccess function itself would need a significant refactor
              // to accept an index or be part of a list builder.
              // For now, I'll make the minimal change that adds curly braces
              // to the onTap callback of the second Expanded widget.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TimetableScreen(),
                ),
              );
            },
            child: _buildQuickAccessButton(
              Icons.schedule_rounded,
              'View Timetable',
              primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 14, color: color),
        ],
      ),
    );
  }

  Widget _buildNextClassCard(Map<String, dynamic> classData, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withBlue(240)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'NEXT CLASS',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Starts at ${classData['startTime']}',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            classData['subjectName'] ?? 'Subject',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Room: ${classData['room'] ?? 'N/A'}',
            style: GoogleFonts.lexend(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSection(
    String classId,
    Color textColor,
    Color subTextColor,
    Color primaryColor,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Access: Subjects',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnrolledCoursesScreen(uid: _uid),
                  ),
                );
              },
              child: Text(
                'All Subjects',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: _db.getSubjects(classId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(); // Loading or error
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Text(
                'No subjects enrolled.',
                style: GoogleFonts.lexend(color: subTextColor, fontSize: 12),
              );
            }

            // Take up to 4 subjects
            final displayDocs = docs.take(4).toList();

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: displayDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name'] ?? 'Subject';
                // Assign a color based on hash or random (consistent per name)
                final color = [
                  Colors.blue,
                  Colors.purple,
                  const Color(0xff10b981),
                  Colors.orange,
                ][name.hashCode % 4];

                // Assign icon based on name (simple heuristic or default)
                IconData icon = Icons.book_outlined;
                if (name.toLowerCase().contains('math')) {
                  icon = Icons.calculate_outlined;
                } else if (name.toLowerCase().contains('phys')) {
                  icon = Icons.science_outlined;
                } else if (name.toLowerCase().contains('bio')) {
                  icon = Icons.biotech_outlined;
                } else if (name.toLowerCase().contains('hist')) {
                  icon = Icons.history_edu_outlined;
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CourseDetailsScreen(title: name),
                          ),
                        );
                      },
                      child: _buildSubjectItem(
                        name,
                        icon,
                        color,
                        subTextColor,
                        isDarkMode,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubjectItem(
    String label,
    IconData icon,
    Color color,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDarkMode ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Summary',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LearningAnalyticsScreen(uid: _uid),
                    ),
                  );
                },
                child: Text(
                  'View Details',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBar(0.6, false, primaryColor),
                _buildBar(0.8, false, primaryColor),
                _buildBar(0.95, true, primaryColor),
                _buildBar(0.45, false, primaryColor),
                _buildBar(0.75, false, primaryColor),
                _buildBar(0.85, false, primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                return Text(
                  day,
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: subTextColor.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
    double heightFactor,
    bool isHighlighted,
    Color primaryColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 80 * heightFactor,
        decoration: BoxDecoration(
          color: isHighlighted
              ? primaryColor
              : primaryColor.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildOfflineSyncCard(bool isDarkMode, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: successColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: successColor, size: 20),
          const SizedBox(width: 12),
          Text(
            'Ready for offline usage',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: successColor,
            ),
          ),
          const Spacer(),
          Text(
            'Check Status',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: successColor,
            ),
          ),
        ],
      ),
    );
  }
}
