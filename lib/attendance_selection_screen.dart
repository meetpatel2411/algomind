import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_exams_screen.dart';
import 'manage_students_screen.dart';
import 'mark_attendance_screen.dart';
import 'attendance_summary_screen.dart';
import 'widgets/profile_image.dart';

class AttendanceSelectionScreen extends StatefulWidget {
  const AttendanceSelectionScreen({super.key});

  @override
  State<AttendanceSelectionScreen> createState() =>
      _AttendanceSelectionScreenState();
}

class _AttendanceSelectionScreenState extends State<AttendanceSelectionScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);

  int _selectedDateIndex = 1; // Tuesday 12

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
        child: Column(
          children: [
            _buildStatusBar(isDarkMode, textColor),
            _buildHeader(textColor, subTextColor, isDarkMode),
            _buildOfflineBanner(),
            _buildDateScroller(
              surfaceColor,
              borderColor,
              textColor,
              subTextColor,
            ),
            Expanded(
              child: _buildClassesList(
                surfaceColor,
                borderColor,
                textColor,
                subTextColor,
                isDarkMode,
              ),
            ),
            _buildBottomBar(
              surfaceColor,
              borderColor,
              subTextColor,
              isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(bool isDarkMode, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 14, color: textColor),
              const SizedBox(width: 4),
              Icon(Icons.wifi_off, size: 14, color: textColor),
              const SizedBox(width: 4),
              Transform.rotate(
                angle: 1.5708, // 90 degrees in radians
                child: Icon(Icons.battery_full, size: 14, color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color subTextColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: isDarkMode ? backgroundDark : backgroundLight,
        border: Border(
          bottom: BorderSide(color: primaryColor.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance',
                style: GoogleFonts.lexend(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ProfileImage(
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDgejt07EF9MSgZjNM-s0g6YovkAde8QT-NtNCrYjN0zHN8SlI1owZ7wxKG0utEYhn1-HJSnLnp1xB3BFlB6McA8_ynPXo7laY9WC0g9Lb58R4pJ0I9PWu7VbQkvvBWByU_KlNVOdPAafj0_-rrdSH9Z14JtXa6cElckRVJO--EGBHoAtqcjng8gF98KVLCkYifFY_o_qqssxJl5hYNBThbu6HMczgPl3FcdninAWD4d9wh3End-RcHYolE1zYn_oTO9F35tmVD0UY',
                    borderColor: primaryColor.withOpacity(0.2),
                    borderWidth: 2,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'September 2023',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
              Text(
                'Today',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: primaryColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: primaryColor, size: 14),
          const SizedBox(width: 8),
          Text(
            'OFFLINE MODE ACTIVE',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Text(
            'Local changes will sync later',
            style: GoogleFonts.lexend(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDateScroller(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    final List<Map<String, String>> dates = [
      {'day': 'Mon', 'date': '11'},
      {'day': 'Tue', 'date': '12'},
      {'day': 'Wed', 'date': '13'},
      {'day': 'Thu', 'date': '14'},
      {'day': 'Fri', 'date': '15'},
      {'day': 'Sat', 'date': '16'},
    ];

    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedDateIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDateIndex = index),
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 16),
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
                    dates[index]['day']!.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : subTextColor,
                    ),
                  ),
                  Text(
                    dates[index]['date']!,
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : textColor,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
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

  Widget _buildClassesList(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'YOUR SCHEDULE',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: subTextColor.withOpacity(0.6),
              letterSpacing: 1.5,
            ),
          ),
        ),
        _buildClassCard(
          status: 'Completed',
          room: 'Room 402',
          subject: 'Mathematics',
          info: 'Grade 10-A • 42 Students',
          time: '08:30 AM',
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isDarkMode: isDarkMode,
          isSynced: true,
          students: 42,
        ),
        const SizedBox(height: 16),
        _buildClassCard(
          status: 'In Progress',
          room: 'Lab 2',
          subject: 'Physics Practicals',
          info: 'Grade 11-C • 28 Students',
          time: '10:45 AM',
          surfaceColor: surfaceColor,
          borderColor: primaryColor.withOpacity(0.3),
          textColor: textColor,
          subTextColor: subTextColor,
          isDarkMode: isDarkMode,
          isInProgress: true,
          isLocal: true,
        ),
        const SizedBox(height: 16),
        _buildClassCard(
          status: 'Upcoming',
          room: 'Room 102',
          subject: 'History',
          info: 'Grade 09-B • 35 Students',
          time: '01:00 PM',
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isDarkMode: isDarkMode,
          isUpcoming: true,
        ),
        const SizedBox(height: 16),
        _buildClassCard(
          status: 'Upcoming',
          room: 'Gym Hall',
          subject: 'Physical Ed.',
          info: 'Grade 10-A • 42 Students',
          time: '02:30 PM',
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isDarkMode: isDarkMode,
          isUpcoming: true,
          simple: true,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildClassCard({
    required String status,
    required String room,
    required String subject,
    required String info,
    required String time,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
    bool isSynced = false,
    bool isInProgress = false,
    bool isUpcoming = false,
    bool isLocal = false,
    bool simple = false,
    int students = 0,
  }) {
    Color? statusBg;
    Color? statusText;

    if (status == 'Completed') {
      statusBg = const Color(0xffdcfce7);
      statusText = const Color(0xff16a34a);
    } else if (status == 'In Progress') {
      statusBg = primaryColor.withOpacity(0.1);
      statusText = primaryColor;
    } else {
      statusBg = isDarkMode ? const Color(0xff334155) : const Color(0xfff1f5f9);
      statusText = subTextColor;
    }

    return Opacity(
      opacity: isUpcoming ? 0.8 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isInProgress ? 2 : 1),
          boxShadow: isInProgress
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.05),
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: GoogleFonts.lexend(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusText,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              room,
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subject,
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          info,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      time,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isInProgress ? primaryColor : subTextColor,
                      ),
                    ),
                  ],
                ),
                if (!simple) ...[
                  if (isInProgress) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MarkAttendanceScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.fact_check_outlined, size: 20),
                        label: const Text('Mark Attendance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: primaryColor.withOpacity(0.4),
                          textStyle: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ] else if (status == 'Completed') ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            for (int i = 0; i < 2; i++)
                              Align(
                                widthFactor: 0.7,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.white,
                                  child: ProfileImage(
                                    imageUrl:
                                        'https://i.pravatar.cc/100?u=student$i',
                                    size: 20,
                                    borderColor: Colors.transparent,
                                    borderWidth: 0,
                                  ),
                                ),
                              ),
                            Align(
                              widthFactor: 0.7,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: isDarkMode
                                      ? const Color(0xff334155)
                                      : const Color(0xfff1f5f9),
                                  child: Text(
                                    '+40',
                                    style: GoogleFonts.lexend(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: subTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AttendanceSummaryScreen(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                'View Details',
                                style: GoogleFonts.lexend(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else if (isUpcoming) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xff334155)
                                : const Color(0xfff1f5f9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Wait for start',
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.lock_clock_outlined,
                              size: 16,
                              color: subTextColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
            if (isSynced)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.cloud_done_outlined,
                  size: 18,
                  color: Colors.green,
                ),
              ),
            if (isLocal)
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  children: [
                    Text(
                      'Offline',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: subTextColor.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.save_outlined,
                      size: 18,
                      color: subTextColor.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    Color surfaceColor,
    Color borderColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 32, left: 32, right: 32),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.calendar_today_outlined, 'Schedule', true, 0),
          _buildNavItem(
            Icons.assignment_outlined,
            'Exams',
            false,
            1,
            subTextColor,
          ),
          _buildNavItem(
            Icons.group_outlined,
            'Students',
            false,
            2,
            subTextColor,
          ),
          _buildNavItem(
            Icons.settings_outlined,
            'Settings',
            false,
            3,
            subTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    int index, [
    Color? subTextColor,
  ]) {
    return InkWell(
      onTap: () {
        if (index == 0) return;
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ManageExamsScreen()),
          );
        }
        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageStudentsScreen(),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? primaryColor : subTextColor ?? Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? primaryColor : subTextColor ?? Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
