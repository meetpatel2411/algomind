import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'teacher_dashboard.dart';
import 'manage_students_screen.dart';
import 'manage_exams_screen.dart';

class TeachingScheduleScreen extends StatefulWidget {
  const TeachingScheduleScreen({super.key});

  @override
  State<TeachingScheduleScreen> createState() => _TeachingScheduleScreenState();
}

class _TeachingScheduleScreenState extends State<TeachingScheduleScreen>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);

  int _selectedDayIndex = 2; // Wednesday
  int _selectedNavItem = 2; // Schedule

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildSystemStatusBar(isDarkMode, subTextColor),
                _buildHeader(textColor, subTextColor, isDarkMode),
                _buildDayPicker(
                  textColor,
                  subTextColor,
                  surfaceColor,
                  borderColor,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      children: [
                        _buildSessionPast(
                          surfaceColor,
                          borderColor,
                          textColor,
                          subTextColor,
                          isDarkMode,
                        ),
                        _buildSessionLive(
                          surfaceColor,
                          textColor,
                          subTextColor,
                          isDarkMode,
                        ),
                        _buildSessionUpcoming(
                          surfaceColor,
                          borderColor,
                          textColor,
                          subTextColor,
                          isDarkMode,
                        ),
                        _buildBreakDivider(
                          subTextColor,
                          borderColor,
                          isDarkMode,
                        ),
                        _buildSessionFinal(
                          surfaceColor,
                          borderColor,
                          textColor,
                          subTextColor,
                          isDarkMode,
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
            _buildSyncIndicator(),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xffdcfce7).withOpacity(isDarkMode ? 0.1 : 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_done_rounded,
                  color: Color(0xff15803d),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Synced',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff15803d),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.signal_cellular_alt_rounded,
                size: 16,
                color: subTextColor,
              ),
              const SizedBox(width: 6),
              Icon(Icons.wifi_rounded, size: 16, color: subTextColor),
              const SizedBox(width: 6),
              Icon(Icons.battery_full_rounded, size: 16, color: subTextColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color subTextColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Teaching Schedule',
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xff334155)
                      : const Color(0xffe2e8f0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: subTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Wednesday, Oct 25',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPicker(
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    const List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const List<String> dates = ['23', '24', '25', '26', '27', '28'];

    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final bool isSelected = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: Container(
              width: 56,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? null : Border.all(color: borderColor),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[index].toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white.withOpacity(0.7)
                          : subTextColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dates[index],
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionPast(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return _buildTimelineItem(
      isPast: true,
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
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
                      '08:30 AM - 09:45 AM',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: subTextColor.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Advanced Mathematics',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Class 12-A',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                _buildLocationChip('Lab 204', subTextColor, isDarkMode),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: borderColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xff16a34a),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Attendance Recorded',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff16a34a),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionLive(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return _buildTimelineItem(
      isLive: true,
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '10:00 AM - 11:15 AM',
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FadeTransition(
                          opacity: _pulseController,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'LIVE',
                              style: GoogleFonts.lexend(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantum Physics',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Class 11-C',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                _buildLocationChip('Hall B', subTextColor, isDarkMode),
              ],
            ),
            const SizedBox(height: 16),
            Material(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.how_to_reg_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mark Attendance',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionUpcoming(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return _buildTimelineItem(
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
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
                      '11:30 AM - 12:45 PM',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: subTextColor.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Thermodynamics',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Class 11-B',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                _buildLocationChip('Room 102', subTextColor, isDarkMode),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: borderColor.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Pre-lesson material synced',
              style: GoogleFonts.lexend(
                fontSize: 12,
                color: subTextColor.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakDivider(
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 8, bottom: 8),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: borderColor,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: const EdgeInsets.only(left: 0),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xff334155)
                  : const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'LUNCH BREAK',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: subTextColor.withOpacity(0.5),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionFinal(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return _buildTimelineItem(
      isLast: true,
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '01:30 PM - 03:00 PM',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: subTextColor.withOpacity(0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Electromagnetism',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Class 12-B',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            _buildLocationChip('Main Hall', subTextColor, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required Widget content,
    bool isPast = false,
    bool isLive = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 20, bottom: 16),
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 0,
            bottom: isLast ? 24 : 0,
            child: Container(
              width: 2,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : const Color(0xffe2e8f0),
            ),
          ),
          Positioned(
            left: 5,
            top: 24,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isLive
                    ? primaryColor
                    : (isPast ? Colors.transparent : Colors.white),
                border: Border.all(
                  color: isLive
                      ? primaryColor.withOpacity(0.2)
                      : (isPast
                            ? const Color(0xffcbd5e1)
                            : const Color(0xffcbd5e1)),
                  width: isLive ? 4 : 2,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.only(left: 32), child: content),
        ],
      ),
    );
  }

  Widget _buildLocationChip(String label, Color subTextColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xff334155).withOpacity(0.5)
            : const Color(0xfff1f5f9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.place_rounded, size: 14, color: subTextColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: subTextColor,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white10 : const Color(0xffe2e8f0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0, subTextColor),
          _buildNavItem(Icons.groups_rounded, 'Students', 1, subTextColor),
          _buildNavItem(
            Icons.calendar_month_rounded,
            'Schedule',
            2,
            subTextColor,
            isActivePill: true,
          ),
          _buildNavItem(Icons.assignment_rounded, 'Exams', 3, subTextColor),
          _buildNavItem(Icons.person_rounded, 'Profile', 4, subTextColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    Color subTextColor, {
    bool isActivePill = false,
  }) {
    final bool isSelected = _selectedNavItem == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TeacherDashboard()),
            (route) => false,
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageStudentsScreen(),
            ),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ManageExamsScreen()),
          );
        }
        setState(() => _selectedNavItem = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActivePill)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: primaryColor, size: 24),
            )
          else
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

  Widget _buildSyncIndicator() {
    return Positioned(
      bottom: 24,
      right: 20,
      child: Container(
        margin: const EdgeInsets.only(bottom: 100),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xff0f172a),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.wifi_off_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
