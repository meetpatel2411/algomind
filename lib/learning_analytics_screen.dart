import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/profile_image.dart';
import 'widgets/student_bottom_navigation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database_service.dart';
import 'widgets/connectivity_indicator.dart';

class LearningAnalyticsScreen extends StatefulWidget {
  final String? uid;
  const LearningAnalyticsScreen({super.key, this.uid});

  @override
  State<LearningAnalyticsScreen> createState() =>
      _LearningAnalyticsScreenState();
}

class _LearningAnalyticsScreenState extends State<LearningAnalyticsScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  String _selectedFilter = "All Subjects";

  @override
  Widget build(BuildContext context) {
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
      body: ConnectivityIndicator(
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: DatabaseService().getUserProfile(
                  widget.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '',
                ),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // If we have a user profile, we can fetch attendance
                  final String studentId =
                      widget.uid ??
                      FirebaseAuth.instance.currentUser?.uid ??
                      '';
                  final String? classId = userSnapshot.data?['classId'];

                  return StreamBuilder<QuerySnapshot>(
                    stream: DatabaseService().getSubjects(classId),
                    builder: (context, subjectsSnapshot) {
                      final List<String> subjectFilters = ["All Subjects"];
                      final Map<String, String> subjectIdToName = {};
                      if (subjectsSnapshot.hasData) {
                        for (var doc in subjectsSnapshot.data!.docs) {
                          final name = doc['name'] as String;
                          subjectFilters.add(name);
                          subjectIdToName[doc.id] = name;
                        }
                      }

                      return StreamBuilder<QuerySnapshot>(
                        stream: DatabaseService().getStudentAttendanceHistory(
                          studentId,
                        ),
                        builder: (context, attendanceSnapshot) {
                          if (attendanceSnapshot.hasError) {
                            return Center(
                              child: Text(
                                "Error loading attendance: ${attendanceSnapshot.error}",
                                style: GoogleFonts.lexend(color: Colors.red),
                              ),
                            );
                          }

                          return StreamBuilder<QuerySnapshot>(
                            stream: DatabaseService().getStudentExamResults(
                              studentId,
                            ),
                            builder: (context, examsSnapshot) {
                              if (examsSnapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "Error loading exams: ${examsSnapshot.error}",
                                    style: GoogleFonts.lexend(
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              }

                              // 1. Calculate General Stats
                              double attendancePct = 0.0;
                              String attendanceTrend = "No Data";
                              if (attendanceSnapshot.hasData &&
                                  attendanceSnapshot.data!.docs.isNotEmpty) {
                                final allDocs = attendanceSnapshot.data!.docs;
                                final docs = _selectedFilter == "All Subjects"
                                    ? allDocs
                                    : allDocs
                                          .where(
                                            (doc) =>
                                                (doc.data()
                                                    as Map)['subjectName'] ==
                                                _selectedFilter,
                                          )
                                          .toList();

                                final total = docs.length;
                                final present = docs
                                    .where(
                                      (doc) =>
                                          (doc.data()
                                              as Map<
                                                String,
                                                dynamic
                                              >)['status'] ==
                                          'Present',
                                    )
                                    .length;
                                attendancePct = total > 0
                                    ? (present / total)
                                    : 0.0;
                                attendanceTrend = "Total $total sessions";
                              }

                              double totalExamPct = 0.0;
                              int examCount = 0;
                              if (examsSnapshot.hasData &&
                                  examsSnapshot.data!.docs.isNotEmpty) {
                                final allExams = examsSnapshot.data!.docs;
                                final exams = _selectedFilter == "All Subjects"
                                    ? allExams
                                    : allExams
                                          .where(
                                            (doc) =>
                                                (doc.data()
                                                    as Map)['subjectName'] ==
                                                _selectedFilter,
                                          )
                                          .toList();

                                for (var doc in exams) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final marks =
                                      (data['marksObtained'] as num?)
                                          ?.toDouble() ??
                                      0.0;
                                  final total =
                                      (data['totalMarks'] as num?)
                                          ?.toDouble() ??
                                      100.0;
                                  if (total > 0) {
                                    totalExamPct += (marks / total);
                                    examCount++;
                                  }
                                }
                              }
                              double gpa = examCount > 0
                                  ? (totalExamPct / examCount) * 4.0
                                  : 0.0;
                              String gpaString = gpa.toStringAsFixed(2);

                              // 2. Calculate Subject Stats (Attendance vs Marks)
                              final Map<String, Map<String, dynamic>>
                              subjectBarStats = {};

                              // Initialize with real subjects
                              for (var name in subjectIdToName.values) {
                                subjectBarStats[name] = {
                                  'attPct': 0.0,
                                  'markPct': 0.0,
                                  'attCount': 0,
                                  'markCount': 0,
                                };
                              }

                              if (attendanceSnapshot.hasData) {
                                for (var doc in attendanceSnapshot.data!.docs) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final subName =
                                      data['subjectName'] as String?;
                                  if (subName != null &&
                                      subjectBarStats.containsKey(subName)) {
                                    if (data['status'] == 'Present') {
                                      subjectBarStats[subName]!['attCount'] +=
                                          1;
                                    }
                                  }
                                }
                              }

                              if (examsSnapshot.hasData) {
                                for (var doc in examsSnapshot.data!.docs) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final subName =
                                      data['subjectName'] as String?;
                                  if (subName != null &&
                                      subjectBarStats.containsKey(subName)) {
                                    final m =
                                        (data['marksObtained'] as num?)
                                            ?.toDouble() ??
                                        0;
                                    final t =
                                        (data['totalMarks'] as num?)
                                            ?.toDouble() ??
                                        100;
                                    subjectBarStats[subName]!['markPct'] +=
                                        (m / t);
                                    subjectBarStats[subName]!['markCount'] += 1;
                                  }
                                }
                              }

                              // Finalize averages
                              subjectBarStats.forEach((name, stats) {
                                // Attendance average (simulated denominator if total sessions per subject unknown)
                                // For demo, we'll use total attendance docs per subject if we can,
                                // but since we only have flat attendance records, we'll assume a base of 5 for scaling
                                int totalSubSessions =
                                    attendanceSnapshot.data?.docs
                                        .where(
                                          (d) =>
                                              (d.data()
                                                  as Map)['subjectName'] ==
                                              name,
                                        )
                                        .length ??
                                    0;
                                stats['attPct'] = totalSubSessions > 0
                                    ? (stats['attCount'] / totalSubSessions)
                                    : 0.0;
                                stats['markPct'] = stats['markCount'] > 0
                                    ? (stats['markPct'] / stats['markCount'])
                                    : 0.0;
                              });

                              // 3. Performance Over Time (Real Trend)
                              final List<double> trendPoints = [
                                0.5,
                                0.6,
                                0.55,
                                0.7,
                                0.85,
                              ]; // Default
                              if (examsSnapshot.hasData &&
                                  examsSnapshot.data!.docs.isNotEmpty) {
                                // Filter exams for trend
                                final allExams = examsSnapshot.data!.docs;
                                final filteredExams =
                                    _selectedFilter == "All Subjects"
                                    ? allExams
                                    : allExams
                                          .where(
                                            (doc) =>
                                                (doc.data()
                                                    as Map)['subjectName'] ==
                                                _selectedFilter,
                                          )
                                          .toList();

                                // Sort by date and take latest 5 average percentages
                                final sortedExams = filteredExams
                                  ..sort((a, b) {
                                    final ta =
                                        (a.data() as Map)['submittedAt']
                                            as Timestamp?;
                                    final tb =
                                        (b.data() as Map)['submittedAt']
                                            as Timestamp?;
                                    return (ta?.millisecondsSinceEpoch ?? 0)
                                        .compareTo(
                                          tb?.millisecondsSinceEpoch ?? 0,
                                        );
                                  });

                                if (sortedExams.isNotEmpty) {
                                  trendPoints.clear();
                                  for (var doc in sortedExams.take(5)) {
                                    final d = doc.data() as Map;
                                    final m =
                                        (d['marksObtained'] as num?)
                                            ?.toDouble() ??
                                        0;
                                    final t =
                                        (d['totalMarks'] as num?)?.toDouble() ??
                                        100;
                                    trendPoints.add(m / t);
                                  }
                                  while (trendPoints.length < 2)
                                    trendPoints.insert(0, 0.5); // Padding
                                }
                              }

                              return SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 110),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeader(
                                      isDarkMode,
                                      textColor,
                                      subTextColor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 16),
                                          _buildQuickStats(
                                            attendancePct,
                                            attendanceTrend,
                                            gpaString, // Pass real GPA
                                            surfaceColor,
                                            textColor,
                                            subTextColor,
                                            borderColor,
                                          ),
                                          const SizedBox(height: 24),
                                          _buildSubjectFilter(
                                            isDarkMode,
                                            surfaceColor,
                                            textColor,
                                            subTextColor,
                                            borderColor,
                                            subjectFilters,
                                          ),
                                          const SizedBox(height: 24),
                                          _buildPerformanceChart(
                                            surfaceColor,
                                            textColor,
                                            subTextColor,
                                            borderColor,
                                            trendPoints,
                                          ),
                                          const SizedBox(height: 24),
                                          _buildProgressIndicators(
                                            surfaceColor,
                                            textColor,
                                            subTextColor,
                                            borderColor,
                                          ),
                                          const SizedBox(height: 24),
                                          _buildAttendanceMarksChart(
                                            surfaceColor,
                                            textColor,
                                            subTextColor,
                                            borderColor,
                                            _selectedFilter == "All Subjects"
                                                ? subjectBarStats
                                                : {
                                                    _selectedFilter:
                                                        subjectBarStats[_selectedFilter] ??
                                                        {
                                                          'attPct': 0.0,
                                                          'markPct': 0.0,
                                                        },
                                                  },
                                          ),
                                          const SizedBox(height: 24),
                                          _buildAchievementCard(),
                                          const SizedBox(height: 24),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StudentBottomNavigation(
                  currentIndex: 3,
                  isDarkMode: isDarkMode,
                  uid: widget.uid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Learning Analytics",
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "LOCAL SYNC: 2M AGO",
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: subTextColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ProfileImage(
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuA--YFA4M-DobLnR5985RrHOfxeu1gXZfntu9O4exPvieU0T_73-FymVqoxlW7dkj9wbdbGz9hQiP2rp4MGP_wTYQESqyuUie7Qa__D9OrYrmvnDlv1CiWqkbw2TQi3jn_Tf0L5fIrVgs76yiRtYiWxy97F-urPhCiBu7DluSH4P2bS9wf8j65yk0q8WsEa6BZs8vnTZKFC2YTVlukSAE2YJILo_mmCOT-rKV3aU6UOqnrbyWPw-jwpwRlRMys0eNQabQ3TfKIRKTc',
            size: 44,
            borderColor: primaryColor.withValues(alpha: 0.2),
            borderWidth: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    double attendancePct,
    String attendanceTrend,
    String gpa,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            "Current GPA",
            gpa,
            "+0.0", // Mock trend for now
            Colors.green,
            surfaceColor,
            textColor,
            subTextColor,
            borderColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            "Attendance",
            "${(attendancePct * 100).toInt()}%",
            attendanceTrend,
            subTextColor,
            surfaceColor,
            textColor,
            subTextColor,
            borderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String trend,
    Color trendColor,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: label == "Current GPA" ? primaryColor : textColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                trend,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: trendColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilter(
    bool isDarkMode,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    List<String> filters,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          bool isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : surfaceColor,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected ? null : Border.all(color: borderColor),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? subTextColor : Colors.grey.shade700),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceChart(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    List<double> points,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Performance Over Time",
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Icon(Icons.more_horiz, color: subTextColor, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: PerformanceLinePainter(
                primaryColor: primaryColor,
                isDarkMode: Theme.of(context).brightness == Brightness.dark,
                points: points,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["JAN", "FEB", "MAR", "APR", "MAY"].map((month) {
              return Text(
                month,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: subTextColor,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildCircularProgress(
            "Syllabus",
            0.78,
            "12/15 Modules",
            surfaceColor,
            textColor,
            subTextColor,
            borderColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCircularProgress(
            "Assignments",
            0.92,
            "Completed",
            surfaceColor,
            textColor,
            subTextColor,
            borderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress(
    String label,
    double value,
    String subLabel,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
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
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    label == "Syllabus"
                        ? primaryColor
                        : primaryColor.withValues(alpha: 0.6),
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                "${(value * 100).toInt()}%",
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subLabel,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceMarksChart(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    Map<String, Map<String, dynamic>> stats,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attendance vs Marks",
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    "Subject Correlation",
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _chartLegendItem("Mark", primaryColor),
                  const SizedBox(width: 8),
                  _chartLegendItem("Att.", primaryColor.withValues(alpha: 0.2)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...stats.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSubjectBar(
                e.key,
                e.value['markPct'],
                e.value['attPct'],
                subTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            color: const Color(0xff94a3b8),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectBar(
    String subject,
    double primaryVal,
    double secondaryVal,
    Color subTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subject,
          style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: (primaryVal * 100).toInt(),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: (secondaryVal * 100).toInt(),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${(primaryVal * 100).toInt()}%",
              style: GoogleFonts.lexend(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: subTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Top 5% in Mathematics",
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "You've outperformed 95% of your class this month. Keep it up!",
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: const Color(0xff64748b),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PerformanceLinePainter extends CustomPainter {
  final Color primaryColor;
  final bool isDarkMode;
  final List<double> points;

  PerformanceLinePainter({
    required this.primaryColor,
    required this.isDarkMode,
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = isDarkMode
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.shade100
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i < 4; i++) {
      double y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final Paint linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    final List<Offset> pointsList = [];
    final double stepX = size.width / (points.length - 1);
    for (int i = 0; i < points.length; i++) {
      pointsList.add(Offset(i * stepX, size.height * (1 - points[i])));
    }

    path.moveTo(pointsList[0].dx, pointsList[0].dy);
    for (int i = 1; i < pointsList.length; i++) {
      // Use cubic curves for smooth line like SVG
      double xc = (pointsList[i - 1].dx + pointsList[i].dx) / 2;
      double yc = (pointsList[i - 1].dy + pointsList[i].dy) / 2;
      path.quadraticBezierTo(
        pointsList[i - 1].dx,
        pointsList[i - 1].dy,
        xc,
        yc,
      );
    }
    // Final point
    path.lineTo(pointsList.last.dx, pointsList.last.dy);

    canvas.drawPath(path, linePaint);

    // Gradient below the line
    final Path fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.15),
          primaryColor.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Points
    final Paint pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final Paint pointBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < pointsList.length; i++) {
      canvas.drawCircle(
        pointsList[i],
        i == pointsList.length - 1 ? 4 : 3,
        pointPaint,
      );
      canvas.drawCircle(
        pointsList[i],
        i == pointsList.length - 1 ? 4 : 3,
        pointBorderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
