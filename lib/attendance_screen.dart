import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);
  final Color dangerColor = const Color(0xffef4444);
  final Color warningColor = const Color(0xfff59e0b);

  int _selectedIndex = 3; // Analytics/Attendance is active

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
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                    textColor,
                    subTextColor,
                    surfaceColor,
                    isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildAttendanceSummary(
                          surfaceColor,
                          textColor,
                          subTextColor,
                          borderColor,
                          isDarkMode,
                        ),
                        const SizedBox(height: 16),
                        _buildCalendarCard(
                          surfaceColor,
                          textColor,
                          subTextColor,
                          borderColor,
                          isDarkMode,
                        ),
                        const SizedBox(height: 16),
                        _buildStatsGrid(
                          surfaceColor,
                          textColor,
                          subTextColor,
                          borderColor,
                          isDarkMode,
                        ),
                        const SizedBox(height: 16),
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
              child: _buildBottomNav(surfaceColor, subTextColor, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.chevron_left_rounded, color: textColor),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Attendance',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.cloud_done_rounded, size: 14, color: subTextColor),
              const SizedBox(width: 4),
              Text(
                'Synced',
                style: GoogleFonts.lexend(fontSize: 12, color: subTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Attendance',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '94.2%',
                style: GoogleFonts.lexend(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 12, color: successColor),
                    const SizedBox(width: 4),
                    Text(
                      'EXCELLENT',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: CircularProgressIndicator(
                      value: 0.942,
                      strokeWidth: 8,
                      backgroundColor: isDarkMode
                          ? Colors.white10
                          : const Color(0xfff1f5f9),
                      valueColor: AlwaysStoppedAnimation<Color>(successColor),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: successColor,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'October 2023',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.chevron_left_rounded, color: subTextColor),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(textColor, subTextColor, isDarkMode),
          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend(successColor, 'Present'),
              _buildLegend(dangerColor, 'Absent'),
              _buildLegend(
                isDarkMode ? Colors.white12 : const Color(0xffe2e8f0),
                'Holiday',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    final List<String> weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    // Mock data for Oct 2023: Starts on Sunday (but design shows empty slots)
    // Actually HTML shows 5 empty slots, then day 1.
    final List<Widget> days = [];

    for (var day in weekdays) {
      days.add(
        Center(
          child: Text(
            day,
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: subTextColor.withOpacity(0.5),
              letterSpacing: 1,
            ),
          ),
        ),
      );
    }

    // Empty slots
    for (int i = 0; i < 5; i++) {
      days.add(const SizedBox(height: 48));
    }

    // Days 1-22
    for (int i = 1; i <= 22; i++) {
      Color? dotColor;
      bool isHoliday =
          i == 4 || i == 5 || i == 11 || i == 12 || i == 18 || i == 19;
      bool isAbsent = i == 3 || i == 16;
      bool isPresent = !isHoliday && !isAbsent && i <= 20;
      bool isToday = i == 20;

      if (isPresent) dotColor = successColor;
      if (isAbsent) dotColor = dangerColor;

      days.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: isToday
              ? BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                i.toString(),
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isHoliday
                      ? subTextColor.withOpacity(0.3)
                      : (isToday ? primaryColor : textColor),
                ),
              ),
              const SizedBox(height: 4),
              if (dotColor != null)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: days,
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.lexend(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xff94a3b8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatItem(
          'Total Days',
          '22',
          subTextColor,
          textColor,
          surfaceColor,
          borderColor,
        ),
        _buildStatItem(
          'Present',
          '20',
          successColor,
          successColor,
          surfaceColor,
          borderColor,
        ),
        _buildStatItem(
          'Absent',
          '2',
          dangerColor,
          dangerColor,
          surfaceColor,
          borderColor,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: labelColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineSyncCard(bool isDarkMode, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0x1a94a3b8) : const Color(0xfff1f5f9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xff334155) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.offline_bolt_rounded,
              color: Colors.blueGrey.withOpacity(0.5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Sync Active',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white70
                        : const Color(0xff334155),
                  ),
                ),
                Text(
                  'Viewing cached data for October. Changes will sync when online.',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    color: isDarkMode ? Colors.white38 : Colors.grey,
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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white10 : const Color(0xffe2e8f0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0, subTextColor),
          _buildNavItem(Icons.school_rounded, 'Learn', 1, subTextColor),
          _buildNavItem(Icons.assignment_rounded, 'Exams', 2, subTextColor),
          _buildNavItem(
            Icons.insert_chart_outlined_rounded,
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
    return Column(
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
    );
  }
}
