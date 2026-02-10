import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final Color failureColor = const Color(0xfff43f5e);

  int _selectedNavItem = 1;

  final List<Map<String, dynamic>> _students = [
    {
      'name': 'Benjamin Carter',
      'id': 'RM-2024-041',
      'score': '92/100',
      'status': 'Pass',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAMClegwmL9_ASZyQKAcBzfnZUwEKpXFs5vO67HcQ_K7vriSu2oDhAdpdSDdI5IpHlmXVYpsA2uMoxspDDgsIAftH-HammUaQgUAnribLl9ulQLfG-FcU_Hnup8Fn76MTSun8TSdYLmZEKnnL5bv_al9uNtM9gk8DWGJGMTcacj_G3CJv5WsnCQcPxSrGAy9w58hT7Pw8OWjcrnaeiQ396Zw-NaLpsj1XVseSIKtETULUE40O_r6C5rWZ0W9O5cufD1enaG-YuTyd8',
    },
    {
      'name': 'Amelia Watson',
      'id': 'RM-2024-018',
      'score': '85/100',
      'status': 'Pass',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAqwLeUs4dC8TmQ-vUQh39vRzRtTHOmd0xY9WnHPDLqBAcKtaULvuJu9TfydKO3deNuUT2XektJU6X1YPLyrxIobD9HsPGuMuVQ7EIW9xeD54pJRdxk3gzgPP35UYZT2HyhZ3SF6GM1oR6BSmNjDBH9zT8JQI3mudlOLhRBpoe3-ceS-DMlI3b1qvJ-FT5fVIIol0kZqbGgB9E0bY8bahWNKpsV5NkhIiHX80YBhsNLkOegDOUOmjetOFjJgfyXcakZExGjMr9bQJ0',
    },
    {
      'name': 'David Nguyen',
      'id': 'RM-2024-092',
      'score': '34/100',
      'status': 'Fail',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDI3mUwdlbNXHGgq6074xSw4LmLjhSHAkNo3KDiuHBaGI_n70yK14wqQ7NKAhByx3JAr0ZdGBo4ukXaDP5pNrXYOUH83l-fTe7QJXujBue-ZBk9MGG3zPkK6A9TgO6-6VtKwIrl965QBGRDJms2W4YSwZpI66NfKnLD4pdRNTBRDf7azW8AVxc2qznfyhNS3JMwknI0eQIvEaTdJWf8DU6v7_xxTUq5UeOL9jrHu-XMa0_SxanB0A8Yz-_T2QfYQ-HhcajV7IuGJkU',
    },
    {
      'name': 'Sarah Jenkins',
      'id': 'RM-2024-055',
      'score': '78/100',
      'status': 'Pass',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCblCObSpmyQBovIqEFR5B_tw6r_mz6WskM7psXPwi9kQIFM7u2hYna5NAR8OxTwlkSFwORqcgOx9avv3ewFdquqc2VFB6ARoUAndnbOYoJC2-QvMlJNNq2dqoUurmlTxKRswM0c8A2DFJvjqjuxGPaoYOV0jQ34ADOCDLP6OVnFEro715K1uyuRsSJhBEXKJzi1LdlvQCq4wG-fWqc1e8OGEPYjIllWhFUtSpJHcYSIJxg_sY8aQsBpooAfmAZhKJrMUN67IJWpDg',
    },
    {
      'name': 'Marcus King',
      'id': 'RM-2024-112',
      'score': '28/100',
      'status': 'Fail',
      'image': '',
    },
  ];

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

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildSystemStatusBar(isDarkMode, subTextColor),
                _buildHeader(isDarkMode, textColor, subTextColor),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildSummaryCard(textColor),
                        const SizedBox(height: 24),
                        _buildStatsGrid(
                          surfaceColor,
                          borderColor,
                          subTextColor,
                          textColor,
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
                  color: primaryColor.withOpacity(0.1),
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
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                  color: subTextColor.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: subTextColor.withOpacity(0.5),
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

  Widget _buildSummaryCard(Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
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
                color: Colors.white.withOpacity(0.1),
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
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '78.4%',
                    style: GoogleFonts.lexend(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+2.4% from Midterms',
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
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
                        progress: 0.784,
                        color: Colors.white,
                        bgColor: Colors.white.withOpacity(0.2),
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
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'TOTAL PASSED',
            '26',
            '/ 30',
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
            '04',
            '/ 30',
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
                    color: subTextColor.withOpacity(0.5),
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
            color: subTextColor.withOpacity(0.5),
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
    final bool isPass = student['status'] == 'Pass';
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
            child: student['image'] != ''
                ? ProfileImage(
                    imageUrl: student['image'],
                    size: 44,
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                  )
                : Text(
                    student['name'].split(' ').map((e) => e[0]).join(''),
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
                  student['name'],
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
                    color: subTextColor.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    student['score'],
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
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
                        student['status'].toUpperCase(),
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: subTextColor.withOpacity(0.3),
                size: 18,
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
        color: surfaceColor.withOpacity(0.95),
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
            color: isSelected ? primaryColor : subTextColor.withOpacity(0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? primaryColor : subTextColor.withOpacity(0.6),
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
