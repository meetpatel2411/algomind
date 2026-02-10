import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_students_screen.dart';
import 'manage_exams_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);

  int _selectedIndex = 0;

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
                _buildStatusBar(isDarkMode, subTextColor),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(textColor, subTextColor, isDarkMode),
                        const SizedBox(height: 16),
                        _buildStatsRow(
                          isDarkMode,
                          subTextColor,
                          surfaceColor,
                          borderColor,
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Actions',
                                style: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildQuickActionsGrid(
                                surfaceColor,
                                borderColor,
                                isDarkMode,
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Today's Classes",
                                    style: GoogleFonts.lexend(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'View All',
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTodayClassItem(
                                'Advanced Physics',
                                'Grade 12 • 11:30 AM',
                                'ROOM 402',
                                Icons.science_rounded,
                                surfaceColor,
                                borderColor,
                                textColor,
                                subTextColor,
                              ),
                              const SizedBox(height: 12),
                              _buildTodayClassItem(
                                'Calculus II',
                                'Grade 11 • 01:15 PM',
                                'LAB B',
                                Icons.functions_rounded,
                                surfaceColor,
                                borderColor,
                                textColor,
                                subTextColor,
                              ),
                            ],
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

  Widget _buildStatusBar(bool isDarkMode, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                'Synced Offline',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
            ],
          ),
          Text(
            '10:45 AM',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color subTextColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Mr. Smith',
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                'Welcome back to your classroom',
                style: GoogleFonts.lexend(fontSize: 14, color: subTextColor),
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDDJ0xT_gismssEV3tDJT-5kYdGVXCrGNSCNKwmxu_icHAUrDUt8owJFEtSDe1qLPCXqxnROGnBHSIZ7GH-U6H3SMmGMkkJ1Ca6uCEO3HwTYcwMyyMIJgaAd-70rgAIsHbISjIG4SRNf8H5PQc0evW9-XY5d2A7fH_stOAZUy-RyDk09YD-JA16RkWy6use7JvQlpOkiNWqQ2cyujIfT8bjohE5T6AytBDjzLWE68a6BXk7LCzNDZd-p632NC373yt71pGpNoehdYk',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? backgroundDark : backgroundLight,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    bool isDarkMode,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatCard(
            '124',
            'Total Students',
            Icons.groups_rounded,
            primaryColor.withOpacity(0.1),
            primaryColor,
            surfaceColor,
            borderColor,
            subTextColor,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            '03',
            'Exams Active',
            Icons.assignment_rounded,
            const Color(0xfffff7ed),
            const Color(0xffea580c),
            surfaceColor,
            borderColor,
            subTextColor,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            '18',
            'Pending Eval.',
            Icons.pending_actions_rounded,
            const Color(0xfff5f3ff),
            const Color(0xff7c3aed),
            surfaceColor,
            borderColor,
            subTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color iconBgColor,
    Color iconColor,
    Color surfaceColor,
    Color borderColor,
    Color subTextColor,
  ) {
    return Container(
      width: 160,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(
    Color surfaceColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          'Manage Students',
          Icons.person_search_rounded,
          primaryColor,
          Colors.white,
          true,
          surfaceColor,
          borderColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageStudentsScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          'Attendance',
          Icons.assignment_turned_in_rounded,
          surfaceColor,
          primaryColor,
          false,
          surfaceColor,
          borderColor,
        ),
        _buildActionCard(
          'Create Exam',
          Icons.add_task_rounded,
          surfaceColor,
          primaryColor,
          false,
          surfaceColor,
          borderColor,
        ),
        _buildActionCard(
          'Courses',
          Icons.auto_stories_rounded,
          surfaceColor,
          primaryColor,
          false,
          surfaceColor,
          borderColor,
        ),
        _buildActionCard(
          'Timetable',
          Icons.calendar_today_rounded,
          surfaceColor,
          primaryColor,
          false,
          surfaceColor,
          borderColor,
        ),
        _buildActionCard(
          'Reports',
          Icons.analytics_rounded,
          surfaceColor,
          primaryColor,
          false,
          surfaceColor,
          borderColor,
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String label,
    IconData icon,
    Color bgColor,
    Color contentColor,
    bool isPrimary,
    Color surfaceColor,
    Color borderColor, {
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? bgColor : surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary ? null : Border.all(color: borderColor),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: bgColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: contentColor),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayClassItem(
    String subject,
    String details,
    String room,
    IconData icon,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
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
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  details,
                  style: GoogleFonts.lexend(fontSize: 12, color: subTextColor),
                ),
              ],
            ),
          ),
          Text(
            room,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: subTextColor.withOpacity(0.6),
              letterSpacing: 0.5,
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
          _buildNavItem(Icons.school_rounded, 'Students', 1, subTextColor),
          _buildNavItem(
            Icons.assignment_turned_in_rounded,
            'Attendance',
            2,
            subTextColor,
          ),
          _buildNavItem(Icons.history_edu_rounded, 'Exams', 3, subTextColor),
          _buildNavItem(Icons.menu_book_rounded, 'Courses', 4, subTextColor),
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
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageStudentsScreen(),
            ),
          );
        }
        if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ManageExamsScreen()),
          );
        }
        setState(() => _selectedIndex = index);
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
