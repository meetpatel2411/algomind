import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'services/database_service.dart';
import 'widgets/profile_image.dart';
import 'widgets/student_bottom_navigation.dart';
import 'settings_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  final Map<String, String> studentData;
  const StudentProfileScreen({super.key, required this.studentData});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);

  int _selectedTabIndex = 0;

  final DatabaseService _db = DatabaseService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
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
        : const Color(0xffe2e8f0);

    return Scaffold(
      backgroundColor: bgColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) return const SizedBox();

          // Prepare student data for widgets
          final Map<String, String> studentData = {
            'name': userData['fullName'] ?? 'Student',
            'image': userData['imageUrl'] ?? '',
            'details':
                'Class ${userData['className'] ?? ''}-${userData['section'] ?? ''}',
            'rollNo': userData['rollNumber'] ?? 'N/A',
          };

          return SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(isDarkMode, textColor, subTextColor),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _buildSummaryCard(
                              studentData,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            const SizedBox(height: 24),
                            _buildMetricsGrid(
                              _uid,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                              isDarkMode,
                            ),
                            const SizedBox(height: 24),
                            _buildRecentActivity(
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            const SizedBox(height: 24),
                            _buildTabbedRecords(
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                              isDarkMode,
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomNav(
                    surfaceColor,
                    subTextColor,
                    isDarkMode,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      color: subTextColor,
                      size: 24,
                    ),
                    Text(
                      'Back',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xff10b981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Offline Synced',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.settings_rounded, color: subTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    Map<String, String> data,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileImage(
            imageUrl: data['image'] ?? '',
            size: 96,
            borderColor: Colors.white,
            borderWidth: 4,
          ),
          const SizedBox(height: 16),
          Text(
            data['name'] ?? '',
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            'Student ID: #${data['rollNo']}',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data['details'] ?? '',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
    String uid,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getStudentAttendanceHistory(uid),
      builder: (context, attendanceSnapshot) {
        double attendancePct = 0.0;
        if (attendanceSnapshot.hasData &&
            attendanceSnapshot.data!.docs.isNotEmpty) {
          final docs = attendanceSnapshot.data!.docs;
          final present = docs
              .where((d) => (d.data() as Map)['status'] == 'Present')
              .length;
          attendancePct = (present / docs.length);
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _db.getStudentExamResults(uid),
          builder: (context, examsSnapshot) {
            double avgMarks = 0.0;
            if (examsSnapshot.hasData && examsSnapshot.data!.docs.isNotEmpty) {
              double totalPct = 0;
              int count = 0;
              for (var doc in examsSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final marks =
                    (data['marksObtained'] as num?)?.toDouble() ?? 0.0;
                final total = (data['totalMarks'] as num?)?.toDouble() ?? 100.0;
                if (total > 0) {
                  totalPct += (marks / total) * 100;
                  count++;
                }
              }
              if (count > 0) avgMarks = totalPct / count;
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                // Attendance Circle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CustomPaint(
                              painter: ProgressRingPainter(
                                progress: attendancePct,
                                primaryColor: successColor,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ),
                          Text(
                            '${(attendancePct * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Attendance',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Avg Marks
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.trending_up_rounded,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        avgMarks.toStringAsFixed(1),
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Avg. Marks (%)',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRecentActivity(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    if (_uid == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 20,
                color: subTextColor.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: _db.getStudentAttendanceHistory(_uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Text(
                  'No recent activity.',
                  style: GoogleFonts.lexend(color: subTextColor, fontSize: 12),
                );
              }

              // Take top 3 recent
              final recentDocs = docs.take(3).toList();

              return Column(
                children: recentDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'Absent';
                  final date = (data['date'] as Timestamp).toDate();
                  final subject = data['subjectName'] ?? 'Class';

                  final isPresent = status == 'Present';
                  final color = isPresent ? successColor : Colors.redAccent;

                  // Format time: "Today, 09:15 AM" or "Feb 12, 10:00 AM"
                  final now = DateTime.now();
                  String timeStr;
                  if (date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day) {
                    timeStr = 'Today';
                  } else if (date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day - 1) {
                    timeStr = 'Yesterday';
                  } else {
                    timeStr = '${date.day}/${date.month}';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildActivityItem(
                      'Marked $status in $subject',
                      timeStr,
                      color,
                      textColor,
                      subTextColor,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    Color dotColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Text(
                time,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  color: subTextColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabbedRecords(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Tabs
          Row(
            children: [
              _buildTab('Academic', 0, textColor, subTextColor),
              _buildTab('Attendance', 1, textColor, subTextColor),
              _buildTab('Personal', 2, textColor, subTextColor),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: _selectedTabIndex == 0
                ? StreamBuilder<QuerySnapshot>(
                    stream: _db.getStudentExamResults(_uid!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return Text(
                          "No academic records",
                          style: GoogleFonts.lexend(color: subTextColor),
                        );
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final marks = data['marksObtained'];
                          final total = data['totalMarks'] ?? 100;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildAcademicRecord(
                              data['subjectName'] ?? 'General',
                              data['examTitle'] ?? 'Exam',
                              "$marks/$total",
                              data['status'] ?? 'Pass',
                              (data['status'] == 'Fail')
                                  ? Colors.red
                                  : successColor,
                              Icons.assignment_turned_in_rounded,
                              isDarkMode,
                              textColor,
                              subTextColor,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  )
                : Column(
                    children: [
                      _buildAcademicRecord(
                        'Mathematics',
                        'Attendance Record',
                        '95%',
                        'Good',
                        successColor,
                        Icons.calendar_today_rounded,
                        isDarkMode,
                        textColor,
                        subTextColor,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor.withValues(
                              alpha: 0.05,
                            ),
                            foregroundColor: primaryColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'View All Records',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    String label,
    int index,
    Color textColor,
    Color subTextColor,
  ) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? primaryColor
                  : subTextColor.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAcademicRecord(
    String subject,
    String testName,
    String score,
    String status,
    Color statusColor,
    IconData icon,
    bool isDarkMode,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black26 : const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white10 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: subject == 'Physics' ? Colors.blue : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  testName,
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    color: subTextColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                status,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(
    Color surfaceColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return StudentBottomNavigation(currentIndex: 4, isDarkMode: isDarkMode);
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final bool isDarkMode;

  ProgressRingPainter({
    required this.progress,
    required this.primaryColor,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 4;

    final backgroundPaint = Paint()
      ..color = isDarkMode ? const Color(0xff334155) : const Color(0xfff1f5f9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
