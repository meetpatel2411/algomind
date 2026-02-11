import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../student_dashboard.dart';
import '../enrolled_courses_screen.dart';
import '../timetable_screen.dart';
import '../student_profile_screen.dart';
import '../learning_analytics_screen.dart';

class StudentBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final bool isDarkMode;
  final String? uid;

  const StudentBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.isDarkMode,
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = isDarkMode
        ? const Color(0xff1e293b)
        : Colors.white;
    final Color subTextColor = isDarkMode
        ? const Color(0xff94a3b8)
        : const Color(0xff64748b);
    final Color borderColor = isDarkMode
        ? Colors.white10
        : const Color(0xffe2e8f0);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            context,
            Icons.grid_view_rounded,
            'Home',
            0,
            subTextColor,
          ),
          _buildNavItem(
            context,
            Icons.local_library_rounded,
            'Courses',
            1,
            subTextColor,
          ),
          _buildNavItem(
            context,
            Icons.schedule_rounded,
            'Schedule',
            2,
            subTextColor,
          ),
          _buildNavItem(
            context,
            Icons.insert_chart_rounded,
            'Analytics',
            3,
            subTextColor,
          ),
          _buildNavItem(
            context,
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
    BuildContext context,
    IconData icon,
    String label,
    int index,
    Color subTextColor,
  ) {
    final bool isSelected = currentIndex == index;
    final Color primaryColor = const Color(0xff0f68e6);

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
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

  void _handleNavigation(BuildContext context, int index) async {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentDashboard(uid: uid)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EnrolledCoursesScreen(uid: uid),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TimetableScreen(uid: uid)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LearningAnalyticsScreen(uid: uid),
          ),
        );
        break;
      case 4: // Profile
        final currentUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
        if (currentUid != null) {
          final userData = await DatabaseService().getUserProfile(currentUid);
          if (userData != null && context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentProfileScreen(
                  studentData: {
                    'name': userData['fullName'] ?? 'Student',
                    'image': userData['imageUrl'] ?? '',
                    'details':
                        'Class ${userData['className'] ?? ''}-${userData['section'] ?? ''}',
                    // Add other fields as expected by StudentProfileScreen
                  },
                ),
              ),
            );
          }
        }
        break;
    }
  }
}
