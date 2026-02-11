import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/database_service.dart';
import 'dart:math' as math;
import 'teacher_dashboard.dart';
import 'manage_students_screen.dart';
import 'widgets/profile_image.dart';

class ExamResultsScreen extends StatefulWidget {
  final Map<String, dynamic> examData;
  const ExamResultsScreen({super.key, required this.examData});

  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);
  final Color failureColor = const Color(0xffef4444);
  final Color warningColor = const Color(0xfff59e0b);

  int _selectedNavItem = 1;
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _students = [];
  Map<String, TextEditingController> _scoreControllers = {};
  Map<String, String> _statuses = {}; // 'Pass', 'Fail', 'Absent'

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    for (var controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final classId = widget.examData['classId'];
      final examId = widget.examData['id'];

      if (classId == null || examId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // 1. Fetch Students
      final studentsSnapshot = await DatabaseService()
          .getStudentsByClass(classId)
          .first;
      final students = studentsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'rollNo': data['rollNo'] ?? 'N/A',
          'image': data['profileImage'],
        };
      }).toList();

      // 2. Fetch Existing Submissions
      final submissionsSnapshot = await DatabaseService()
          .getExamResults(examId)
          .first;
      final submissions = {
        for (var doc in submissionsSnapshot.docs)
          doc.id: doc.data() as Map<String, dynamic>,
      };

      // 3. Merge Data
      _students = students;
      for (var student in _students) {
        final String uid = student['id'];
        final submission = submissions[uid];

        final score = submission != null
            ? submission['marksObtained'].toString()
            : '';
        final status = submission != null ? submission['status'] : 'Pass';

        _scoreControllers[uid] = TextEditingController(text: score);
        _statuses[uid] = status;
      }
    } catch (e) {
      debugPrint('Error fetching results: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveResults() async {
    setState(() => _isSaving = true);
    try {
      final examId = widget.examData['id'];
      final List<Map<String, dynamic>> results = [];

      for (var student in _students) {
        final uid = student['id'];
        final scoreText = _scoreControllers[uid]?.text.trim();

        if (scoreText != null && scoreText.isNotEmpty) {
          final double score = double.tryParse(scoreText) ?? 0;
          results.add({
            'studentId': uid,
            'studentName': student['name'],
            'marksObtained': score,
            'status': _statuses[uid] ?? 'Pass',
            // Metadata for Analytics
            'examTitle': widget.examData['title'] ?? 'Exam',
            'subjectName': widget.examData['subjectName'] ?? 'General',
            'totalMarks': widget.examData['totalMarks'] ?? 100,
            'examDate': widget.examData['date'],
          });
        }
      }

      if (results.isNotEmpty) {
        await DatabaseService().submitExamResults(examId, results);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Results saved successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving results: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Map<String, dynamic> _calculateStats() {
    int totalStudents = _students.length;
    double totalScore = 0;
    int gradedCount = 0;
    int passedCount = 0;
    int failedCount = 0;

    for (var student in _students) {
      final uid = student['id'];
      final scoreText = _scoreControllers[uid]?.text.trim();
      if (scoreText != null && scoreText.isNotEmpty) {
        double score = double.tryParse(scoreText) ?? 0;
        totalScore += score;
        gradedCount++;

        if (_statuses[uid] == 'Pass') {
          passedCount++;
        } else if (_statuses[uid] == 'Fail') {
          failedCount++;
        }
      }
    }

    double avg = gradedCount > 0 ? totalScore / gradedCount : 0;
    int maxMarks = widget.examData['totalMarks'] ?? 100;
    double percentage = maxMarks > 0 ? (avg / maxMarks) * 100 : 0;

    return {
      'average': percentage.toStringAsFixed(1),
      'graded': gradedCount,
      'total': totalStudents,
      'passed': passedCount,
      'failed': failedCount,
    };
  }

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
        : const Color(0xffe2e8f0);

    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveResults,
        backgroundColor: primaryColor,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(
          _isSaving ? 'Saving...' : 'Save Results',
          style: GoogleFonts.lexend(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildSystemStatusBar(isDarkMode, subTextColor),
                _buildHeader(isDarkMode, textColor, subTextColor),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildSummaryCard(textColor, stats),
                              const SizedBox(height: 24),
                              _buildStatsGrid(
                                surfaceColor,
                                borderColor,
                                subTextColor,
                                textColor,
                                stats,
                              ),
                              const SizedBox(height: 24),
                              _buildStudentListHeader(textColor, subTextColor),
                              const SizedBox(height: 12),
                              _buildStudentList(
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
              child: _buildBottomNav(surfaceColor, subTextColor, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusBar(bool isDarkMode, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.signal_cellular_alt_rounded,
                size: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.wifi_rounded,
                size: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              const SizedBox(width: 4),
              Transform.rotate(
                angle: math.pi / 2,
                child: Icon(
                  Icons.battery_full_rounded,
                  size: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Exam Results',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_done_rounded,
                      color: primaryColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'OFFLINE',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              style: GoogleFonts.lexend(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search student name or ID...',
                hintStyle: GoogleFonts.lexend(
                  color: subTextColor.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: subTextColor.withValues(alpha: 0.5),
                ),
                suffixIcon: Icon(Icons.tune_rounded, color: primaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Color textColor, Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLASS PERFORMANCE',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stats['average']}%',
                    style: GoogleFonts.lexend(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Average Score',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CustomPaint(
                      painter: RingPainter(
                        progress:
                            double.tryParse(stats['average'].toString())! / 100,
                        color: Colors.white,
                        bgColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    Color surfaceColor,
    Color borderColor,
    Color subTextColor,
    Color textColor,
    Map<String, dynamic> stats,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'TOTAL PASSED',
            '${stats['passed']}',
            '/ ${stats['graded']}',
            successColor,
            surfaceColor,
            borderColor,
            subTextColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'FAILURES',
            '${stats['failed']}',
            '/ ${stats['graded']}',
            failureColor,
            surfaceColor,
            borderColor,
            subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String total,
    Color valueColor,
    Color surfaceColor,
    Color borderColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: subTextColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  total,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subTextColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentListHeader(Color textColor, Color subTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Student Details',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          'SORT BY SCORE',
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: subTextColor.withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _students.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = _students[index];
        return _buildStudentItem(
          student,
          surfaceColor,
          borderColor,
          textColor,
          subTextColor,
          isDarkMode,
        );
      },
    );
  }

  Widget _buildStudentItem(
    Map<String, dynamic> student,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    final uid = student['id'];
    final status = _statuses[uid] ?? 'Pass';
    final isPass = status == 'Pass';
    final Color statusColor = isPass ? successColor : failureColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white10 : const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: student['image'] != null && student['image'] != ''
                ? ProfileImage(
                    imageUrl: student['image'],
                    size: 44,
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                  )
                : Text(
                    (student['name'] ?? 'Unknown')
                        .split(' ')
                        .map((e) => e[0])
                        .take(2)
                        .join(''),
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] ?? 'Unknown',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'ID: ${student['id']}',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    color: subTextColor.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _scoreControllers[uid],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.lexend(
                      color: subTextColor.withValues(alpha: 0.5),
                    ),
                  ),
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  onChanged: (val) {
                    setState(() {}); // Refresh stats
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Status Toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    _statuses[uid] = status == 'Pass' ? 'Fail' : 'Pass';
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status.toUpperCase(),
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
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
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white10 : const Color(0xffe2e8f0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.grid_view_rounded, 'Dashboard', 0, subTextColor),
          _buildNavItem(Icons.analytics_rounded, 'Results', 1, subTextColor),
          const SizedBox(width: 40), // Space for FAB
          _buildNavItem(Icons.school_rounded, 'Students', 2, subTextColor),
          _buildNavItem(Icons.settings_rounded, 'Settings', 3, subTextColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    Color subTextColor,
  ) {
    final bool isSelected = _selectedNavItem == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TeacherDashboard()),
            (route) => false,
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageStudentsScreen(),
            ),
          );
        }
        setState(() => _selectedNavItem = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? primaryColor
                : subTextColor.withValues(alpha: 0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? primaryColor
                  : subTextColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  RingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 4;

    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
