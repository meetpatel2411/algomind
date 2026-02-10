import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_dashboard.dart';
import 'enrolled_courses_screen.dart';
import 'learning_analytics_screen.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);

  int _selectedIndex = 2; // Timetable is index 2

  // Standardized Nav in previous task:
  // Home (0), Courses (1), Exams (2), Analytics (3), Profile (4).
  // Wait, let me check the standardized nav I implemented earlier.

  int _activeDayIndex = 1; // Tuesday (13) is selected in HTML

  final List<Map<String, String>> _days = [
    {'day': 'Mon', 'date': '12'},
    {'day': 'Tue', 'date': '13'},
    {'day': 'Wed', 'date': '14'},
    {'day': 'Thu', 'date': '15'},
    {'day': 'Fri', 'date': '16'},
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
                _buildHeader(
                  surfaceColor,
                  textColor,
                  subTextColor,
                  borderColor,
                  isDarkMode,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                    child: Column(
                      children: [
                        _buildClassCard(
                          timeStart: '08:00',
                          timeEnd: '09:00',
                          subject: 'Mathematics',
                          instructor: 'Dr. Emily Smith',
                          room: 'Room 302, Block A',
                          status: 'Completed',
                          isDarkMode: isDarkMode,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 16),
                        _buildLiveClassCard(
                          timeStart: '10:15',
                          timeEnd: '11:15',
                          subject: 'Quantum Physics',
                          instructor: 'Prof. Julian Adams',
                          room: 'Physics Lab B, 1st Floor',
                          progress: 0.65,
                          startedAgo: '40m ago',
                          remaining: '20m remaining',
                          isDarkMode: isDarkMode,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        const SizedBox(height: 16),
                        _buildBreakSeparator(isDarkMode, borderColor),
                        const SizedBox(height: 16),
                        _buildClassCard(
                          timeStart: '13:00',
                          timeEnd: '14:00',
                          subject: 'English Literature',
                          instructor: 'Ms. Sarah Jenkins',
                          room: 'Lecture Hall 12',
                          isDarkMode: isDarkMode,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 16),
                        _buildClassCard(
                          timeStart: '14:15',
                          timeEnd: '15:15',
                          subject: 'History of Arts',
                          instructor: 'Prof. Robert Vance',
                          room: 'Studio 04',
                          isDarkMode: isDarkMode,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          borderColor: borderColor,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "End of Tuesday's schedule",
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: subTextColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
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

  Widget _buildHeader(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? surfaceColor : Colors.white,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Timetable',
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_done_rounded,
                        size: 14,
                        color: successColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Synced Offline'.toUpperCase(),
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: subTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  foregroundColor: primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Today',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _days.asMap().entries.map((entry) {
                int idx = entry.key;
                Map<String, String> day = entry.value;
                bool isSelected = _activeDayIndex == idx;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeDayIndex = idx),
                    child: Container(
                      width: 64,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : (isDarkMode ? surfaceColor : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? null
                            : Border.all(color: borderColor),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            day['day']!,
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : subTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day['date']!,
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard({
    required String timeStart,
    required String timeEnd,
    required String subject,
    required String instructor,
    required String room,
    String? status,
    required bool isDarkMode,
    required Color surfaceColor,
    required Color textColor,
    required Color subTextColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeInfo(
            timeStart,
            timeEnd,
            textColor,
            subTextColor,
            borderColor,
            isDarkMode,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subject,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : const Color(0xfff1f5f9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: subTextColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.person_outline_rounded,
                  instructor,
                  subTextColor,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.room_outlined, room, subTextColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveClassCard({
    required String timeStart,
    required String timeEnd,
    required String subject,
    required String instructor,
    required String room,
    required double progress,
    required String startedAgo,
    required String remaining,
    required bool isDarkMode,
    required Color surfaceColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -26,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode ? backgroundDark : backgroundLight,
                  width: 3,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE NOW',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeInfo(
                timeStart,
                timeEnd,
                primaryColor,
                subTextColor,
                primaryColor.withOpacity(0.3),
                isDarkMode,
                isLive: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.person_outline_rounded,
                        instructor,
                        subTextColor,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.room_outlined, room, subTextColor),
                      const SizedBox(height: 12),
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white10
                              : const Color(0xfff1f5f9),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Started $startedAgo',
                            style: GoogleFonts.lexend(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: primaryColor.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            remaining,
                            style: GoogleFonts.lexend(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: primaryColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(
    String start,
    String end,
    Color mainColor,
    Color subColor,
    Color dividerColor,
    bool isDarkMode, {
    bool isLive = false,
  }) {
    return Column(
      children: [
        Text(
          start,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: mainColor,
          ),
        ),
        Container(
          width: 1,
          height: 32,
          color: dividerColor,
          margin: const EdgeInsets.symmetric(vertical: 4),
        ),
        Text(
          end,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: subColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color subTextColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: subTextColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.lexend(fontSize: 12, color: subTextColor),
        ),
      ],
    );
  }

  Widget _buildBreakSeparator(bool isDarkMode, Color borderColor) {
    return Row(
      children: [
        Expanded(child: Divider(color: borderColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.restaurant_rounded,
                size: 16,
                color: (isDarkMode ? Colors.white30 : Colors.black26),
              ),
              const SizedBox(width: 8),
              Text(
                'LUNCH BREAK',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: (isDarkMode ? Colors.white30 : Colors.black26),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: Divider(color: borderColor)),
      ],
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
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LearningAnalyticsScreen(),
            ),
          );
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
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? primaryColor : subTextColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
