import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_dashboard.dart';
import 'enrolled_courses_screen.dart';
import 'timetable_screen.dart';

class LearningAnalyticsScreen extends StatefulWidget {
  const LearningAnalyticsScreen({super.key});

  @override
  State<LearningAnalyticsScreen> createState() =>
      _LearningAnalyticsScreenState();
}

class _LearningAnalyticsScreenState extends State<LearningAnalyticsScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);

  int _selectedIndex = 3; // Analytics index

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
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDarkMode, textColor, subTextColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildQuickStats(
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
                        ),
                        const SizedBox(height: 24),
                        _buildPerformanceChart(
                          surfaceColor,
                          textColor,
                          subTextColor,
                          borderColor,
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
                        ),
                        const SizedBox(height: 24),
                        _buildAchievementCard(),
                        const SizedBox(height: 24),
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
              child: _buildBottomNav(surfaceColor, subTextColor, isDarkMode),
            ),
          ],
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
          Column(
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 2,
              ),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA--YFA4M-DobLnR5985RrHOfxeu1gXZfntu9O4exPvieU0T_73-FymVqoxlW7dkj9wbdbGz9hQiP2rp4MGP_wTYQESqyuUie7Qa__D9OrYrmvnDlv1CiWqkbw2TQi3jn_Tf0L5fIrVgs76yiRtYiWxy97F-urPhCiBu7DluSH4P2bS9wf8j65yk0q8WsEa6BZs8vnTZKFC2YTVlukSAE2YJILo_mmCOT-rKV3aU6UOqnrbyWPw-jwpwRlRMys0eNQabQ3TfKIRKTc',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
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
            "3.82",
            "+0.2",
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
            "94%",
            "Last 30d",
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
            color: Colors.black.withOpacity(0.02),
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
  ) {
    final List<String> filters = [
      "All Subjects",
      "Mathematics",
      "Physics",
      "Biology",
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          bool isSelected = filter == "All Subjects";
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : surfaceColor,
                borderRadius: BorderRadius.circular(30),
                border: isSelected ? null : Border.all(color: borderColor),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
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
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                        : primaryColor.withOpacity(0.6),
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
                  _chartLegendItem("Att.", primaryColor.withOpacity(0.2)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSubjectBar("Mathematics", 0.85, 0.10, subTextColor),
          const SizedBox(height: 16),
          _buildSubjectBar("Physics", 0.72, 0.25, subTextColor),
          const SizedBox(height: 16),
          _buildSubjectBar("Literature", 0.94, 0.04, subTextColor),
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
                  color: primaryColor.withOpacity(0.2),
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
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
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
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
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

  Widget _buildBottomNav(
    Color surfaceColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: hideBottomNavBlur ? surfaceColor : surfaceColor.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white10 : const Color(0xffe2e8f0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.grid_view_rounded, 'Home', 0, subTextColor),
          _buildNavItem(Icons.schedule_rounded, 'Timetable', 2, subTextColor),
          _buildNavItem(
            Icons.local_library_rounded,
            'Courses',
            1,
            subTextColor,
          ),
          _buildNavItem(
            Icons.insert_chart_rounded,
            'Analytics',
            3,
            subTextColor,
          ),
          _buildNavItem(
            Icons.person_outline_rounded,
            'Profile',
            4,
            subTextColor,
          ),
        ],
      ),
    );
  }

  bool get hideBottomNavBlur => false;

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    Color subTextColor,
  ) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == _selectedIndex) return;
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentDashboard()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const EnrolledCoursesScreen(),
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TimetableScreen()),
          );
        } else if (index == 3) {
          return;
        }
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
              fontWeight: FontWeight.bold,
              color: isSelected ? primaryColor : subTextColor.withOpacity(0.6),
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

  PerformanceLinePainter({
    required this.primaryColor,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = isDarkMode
          ? Colors.white.withOpacity(0.05)
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
    final List<Offset> points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.45),
      Offset(size.width * 0.75, size.height * 0.3),
      Offset(size.width, size.height * 0.15),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      // Use cubic curves for smooth line like SVG
      double xc = (points[i - 1].dx + points[i].dx) / 2;
      double yc = (points[i - 1].dy + points[i].dy) / 2;
      path.quadraticBezierTo(points[i - 1].dx, points[i - 1].dy, xc, yc);
    }
    // Final point
    path.lineTo(points.last.dx, points.last.dy);

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
        colors: [primaryColor.withOpacity(0.15), primaryColor.withOpacity(0)],
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

    for (int i = 1; i < points.length; i++) {
      canvas.drawCircle(points[i], i == points.length - 1 ? 4 : 3, pointPaint);
      canvas.drawCircle(
        points[i],
        i == points.length - 1 ? 4 : 3,
        pointBorderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
