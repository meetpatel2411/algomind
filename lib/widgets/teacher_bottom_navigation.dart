import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../teacher_dashboard.dart';
import '../manage_students_screen.dart';
import '../manage_exams_screen.dart';
import '../attendance_screen.dart';
import '../teaching_schedule_screen.dart';
import 'connectivity_bottom_bar.dart';

class TeacherBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final bool isDarkMode;

  const TeacherBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = isDarkMode
        ? const Color(0xff1e293b)
        : Colors.white;
    final Color subTextColor = isDarkMode
        ? const Color(0xff94a3b8)
        : const Color(0xff64748b);
    final Color primaryColor = const Color(0xff0f68e6);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white10 : const Color(0xffe2e8f0),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  Icons.dashboard_rounded,
                  'Dashboard',
                  0,
                  primaryColor,
                  subTextColor,
                ),
                _buildNavItem(
                  context,
                  Icons.groups_rounded,
                  'Students',
                  1,
                  primaryColor,
                  subTextColor,
                ),
                _buildNavItem(
                  context,
                  Icons.assignment_turned_in_rounded,
                  'Attendance',
                  2,
                  primaryColor,
                  subTextColor,
                ),
                _buildNavItem(
                  context,
                  Icons.calendar_month_rounded,
                  'Schedule',
                  3,
                  primaryColor,
                  subTextColor,
                ),
                _buildNavItem(
                  context,
                  Icons.assignment_rounded,
                  'Exams',
                  4,
                  primaryColor,
                  subTextColor,
                ),
              ],
            ),
          ),
          const ConnectivityBottomBar(),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    Color primaryColor,
    Color subTextColor,
  ) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      behavior: HitTestBehavior.opaque,
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

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Helper to push and replace to avoid building a huge stack
    // Exception: Dashboard should basically clear the stack or use pushAndRemoveUntil

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TeacherDashboard()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ManageStudentsScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AttendanceScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TeachingScheduleScreen(),
          ),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ManageExamsScreen()),
        );
        break;
    }
  }
}
