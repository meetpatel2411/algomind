import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/student_bottom_navigation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'services/database_service.dart';
import 'widgets/connectivity_indicator.dart';

class TimetableScreen extends StatefulWidget {
  final String? uid;
  const TimetableScreen({super.key, this.uid});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);

  int _activeDayIndex = 0;
  List<DateTime> _weekDates = [];

  @override
  void initState() {
    super.initState();
    _generateWeekDates();
  }

  void _generateWeekDates() {
    final now = DateTime.now();
    // Start from Monday of current week
    // weekday 1=Mon, 7=Sun
    final monday = now.subtract(Duration(days: now.weekday - 1));
    _weekDates = List.generate(5, (index) => monday.add(Duration(days: index)));

    // Set active day to today if it's Mon-Fri, else Monday
    if (now.weekday <= 5) {
      _activeDayIndex = now.weekday - 1;
    } else {
      _activeDayIndex = 0;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('d').format(date);
  }

  String _formatDay(DateTime date) {
    return DateFormat('E').format(date);
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
      body: ConnectivityIndicator(
        child: SafeArea(
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
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: DatabaseService().getUserProfile(
                        widget.uid ??
                            FirebaseAuth.instance.currentUser?.uid ??
                            '',
                      ),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final classId =
                            userSnapshot.data?['classId'] as String?;

                        if (classId == null || classId.isEmpty) {
                          return Center(
                            child: Text(
                              'Not enrolled in any class.',
                              style: GoogleFonts.lexend(color: subTextColor),
                            ),
                          );
                        }

                        // Fetch schedule for the selected day
                        return StreamBuilder<QuerySnapshot>(
                          stream: DatabaseService().getStudentSchedule(
                            classId,
                            _weekDates[_activeDayIndex],
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy_rounded,
                                      size: 64,
                                      color: subTextColor.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No classes scheduled for today.',
                                      style: GoogleFonts.lexend(
                                        fontSize: 16,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Sort by start time. Firestore query might not be sorted if we filtered by dayOfWeek only.
                            // We need to parse time strings "HH:MM:SS"
                            final docs = snapshot.data!.docs;

                            // Simple sort helper
                            int parseTimeToInt(String time) {
                              final parts = time.split(':');
                              return int.parse(parts[0]) * 60 +
                                  int.parse(parts[1]);
                            }

                            docs.sort((a, b) {
                              final tA = a['startTime'] as String;
                              final tB = b['startTime'] as String;
                              return parseTimeToInt(
                                tA,
                              ).compareTo(parseTimeToInt(tB));
                            });

                            return SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                24,
                                16,
                                120,
                              ),
                              child: Column(
                                children: [
                                  ...docs.map((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    return _buildScheduleItem(
                                      data,
                                      isDarkMode,
                                      surfaceColor,
                                      textColor,
                                      subTextColor,
                                      borderColor,
                                    );
                                  }),
                                  const SizedBox(height: 24),
                                  Text(
                                    "End of ${_formatDay(_weekDates[_activeDayIndex])}'s schedule",
                                    style: GoogleFonts.lexend(
                                      fontSize: 12,
                                      color: subTextColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StudentBottomNavigation(
                  currentIndex: 2,
                  isDarkMode: isDarkMode,
                  uid: widget.uid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem(
    Map<String, dynamic> data,
    bool isDarkMode,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    // Determine if Live
    final startTimeStr = data['startTime'] as String; // "HH:MM:SS"
    final endTimeStr = data['endTime'] as String;

    // Parse to today's DateTime for comparison (assuming schedule repeats weekly)
    final now = DateTime.now();
    // Use _weekDates[_activeDayIndex] to get the date of the card?
    // Determine if the card represents "Today".
    // If _weekDates[_activeDayIndex] is NOT today, then it can't be live now.

    bool isTodaySelected =
        _weekDates[_activeDayIndex].day == now.day &&
        _weekDates[_activeDayIndex].month == now.month &&
        _weekDates[_activeDayIndex].year == now.year;

    bool isLive = false;
    bool isCompleted = false;

    // Simple parsing for HH:MM
    // We only care about time comparison if it IS today
    if (isTodaySelected) {
      final sParts = startTimeStr.split(':');
      final eParts = endTimeStr.split(':');

      final start = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(sParts[0]),
        int.parse(sParts[1]),
      );
      final end = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(eParts[0]),
        int.parse(eParts[1]),
      );

      if (now.isAfter(start) && now.isBefore(end)) {
        isLive = true;
      } else if (now.isAfter(end)) {
        isCompleted = true;
      }
    }

    final subject = data['subjectName'] ?? 'Unknown';
    // Timetable doc has 'room'
    final room = data['room'] ?? 'TBD';
    // 'teacherId' is stored. Need to fetch name or just use placeholder?
    // To save reads, lets use "Instructor" or if we have teacher name in timetable (seed might put it?)
    // Seed puts 'teacherId'.
    final instructor = 'Instructor'; // Fallback

    final timeStart = startTimeStr.substring(0, 5);
    final timeEnd = endTimeStr.substring(0, 5);

    if (isLive) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildLiveClassCard(
          timeStart: timeStart,
          timeEnd: timeEnd,
          subject: subject,
          instructor: instructor,
          room: room,
          progress: 0.5, // Mock progress for now
          startedAgo: 'Just now',
          remaining: 'Ongoing',
          isDarkMode: isDarkMode,
          surfaceColor: surfaceColor,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildClassCard(
        timeStart: timeStart,
        timeEnd: timeEnd,
        subject: subject,
        instructor: instructor,
        room: room,
        status: isCompleted ? 'Completed' : null,
        isDarkMode: isDarkMode,
        surfaceColor: surfaceColor,
        textColor: textColor,
        subTextColor: subTextColor,
        borderColor: borderColor,
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
                onPressed: () {
                  // Set to Today
                  final now = DateTime.now();
                  // find index of today in _weekDates
                  int idx = _weekDates.indexWhere(
                    (d) => d.day == now.day && d.month == now.month,
                  );
                  if (idx != -1) {
                    setState(() {
                      _activeDayIndex = idx;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
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
              children: _weekDates.asMap().entries.map((entry) {
                int idx = entry.key;
                DateTime date = entry.value;
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
                                  color: primaryColor.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _formatDay(date),
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : subTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(date),
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
            color: Colors.black.withValues(alpha: 0.02),
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
                              ? Colors.white.withValues(alpha: 0.05)
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
            color: primaryColor.withValues(alpha: 0.1),
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
                primaryColor.withValues(alpha: 0.3),
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
                              color: primaryColor.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            remaining,
                            style: GoogleFonts.lexend(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: primaryColor.withValues(alpha: 0.7),
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
}
