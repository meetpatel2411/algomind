import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'attendance_recorded_screen.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);
  final Color dangerColor = const Color(0xffef4444);

  final List<Map<String, dynamic>> students = [
    {'roll': '01', 'name': 'Aaron Smith', 'id': 'RM-2023-001', 'status': 'P'},
    {'roll': '02', 'name': 'Bella Thorne', 'id': 'RM-2023-002', 'status': 'P'},
    {'roll': '03', 'name': 'Charlie Davis', 'id': 'RM-2023-003', 'status': 'A'},
    {'roll': '04', 'name': 'Diana Prince', 'id': 'RM-2023-004', 'status': 'P'},
    {'roll': '05', 'name': 'Ethan Hunt', 'id': 'RM-2023-005', 'status': 'P'},
    {
      'roll': '06',
      'name': 'Fiona Gallagher',
      'id': 'RM-2023-006',
      'status': 'P',
    },
    {'roll': '07', 'name': 'George Miller', 'id': 'RM-2023-007', 'status': 'A'},
  ];

  int get presentCount => students.where((s) => s['status'] == 'P').length;
  int get absentCount => students.where((s) => s['status'] == 'A').length;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDarkMode ? backgroundDark : backgroundLight;
    final Color surfaceColor = isDarkMode
        ? const Color(0xff0f172a)
        : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xff1e293b);
    final Color subTextColor = isDarkMode
        ? const Color(0xff94a3b8)
        : const Color(0xff64748b);
    final Color borderColor = isDarkMode
        ? const Color(0xff1e293b)
        : const Color(0xfff1f5f9);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(isDarkMode, surfaceColor, textColor, subTextColor),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildStudentCardWithToggles(
                        index,
                        isDarkMode,
                        surfaceColor,
                        textColor,
                        subTextColor,
                        borderColor,
                      ),
                    );
                  }, childCount: students.length),
                ),
              ),
            ],
          ),
          _buildBottomActionBar(isDarkMode, textColor, subTextColor),
          _buildFloatingStats(),
        ],
      ),
    );
  }

  Widget _buildHeader(
    bool isDarkMode,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
  ) {
    return SliverPadding(
      padding: EdgeInsets.zero,
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? backgroundDark.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            border: Border(
              bottom: BorderSide(
                color: isDarkMode
                    ? Colors.white10
                    : Colors.black.withOpacity(0.05),
              ),
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: Colors.transparent.runtimeType == Color
                  ? ColorFilter.mode(Colors.transparent, BlendMode.dst)
                  : (isDarkMode
                        ? ColorFilter.mode(
                            backgroundDark.withOpacity(0.8),
                            BlendMode.dst,
                          )
                        : ColorFilter.mode(
                            Colors.white.withOpacity(0.8),
                            BlendMode.dst,
                          )),
              // Using a simple container because backdrop filter needs a background
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: primaryColor,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Column(
                            children: [
                              Text(
                                'Mark Attendance',
                                style: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                'Class 10-A • Oct 24, 2023',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.more_horiz_rounded,
                              color: primaryColor,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xff1e293b)
                              : const Color(0xfff1f5f9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search roll no. or name...',
                            hintStyle: GoogleFonts.lexend(
                              fontSize: 14,
                              color: subTextColor,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: subTextColor,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '42 Students Total',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                for (var s in students) {
                                  s['status'] = 'P';
                                }
                              });
                            },
                            icon: const Icon(Icons.done_all_rounded, size: 14),
                            label: const Text('Mark All Present'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor.withOpacity(0.1),
                              foregroundColor: primaryColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Refactored toggle for better state management in mock
  Widget _buildStudentCardWithToggles(
    int index,
    bool isDarkMode,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    final student = students[index];
    final bool isAbsent = student['status'] == 'A';
    final Color rollBg = isAbsent
        ? dangerColor.withOpacity(0.1)
        : primaryColor.withOpacity(0.1);
    final Color rollText = isAbsent ? dangerColor : primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAbsent ? dangerColor.withOpacity(0.3) : borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rollBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    student['roll'],
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: rollText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'],
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'ID: ${student['id']}',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xff1e293b)
                  : const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildStatusOption(
                  'P',
                  student['status'] == 'P',
                  primaryColor,
                  () => setState(() => student['status'] = 'P'),
                ),
                _buildStatusOption(
                  'A',
                  student['status'] == 'A',
                  dangerColor,
                  () => setState(() => student['status'] = 'A'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    String label,
    bool isSelected,
    Color activeColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xff64748b),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(
    bool isDarkMode,
    Color textColor,
    Color subTextColor,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDarkMode
                  ? backgroundDark.withOpacity(0)
                  : backgroundLight.withOpacity(0),
              isDarkMode ? backgroundDark : backgroundLight,
            ],
            stops: const [0, 0.4],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_rounded, size: 12, color: subTextColor),
                const SizedBox(width: 6),
                Text(
                  'OFFLINE MODE ACTIVE - CHANGES SAVED LOCALLY',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: subTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceRecordedScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded, size: 20),
                label: const Text('Save Attendance Offline'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  shadowColor: primaryColor.withOpacity(0.4),
                  textStyle: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingStats() {
    return Positioned(
      top: 180,
      right: 16,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xff4ade80),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${presentCount.toString().padLeft(2, '0')} P',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: dangerColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
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
                  '${absentCount.toString().padLeft(2, '0')} A',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
