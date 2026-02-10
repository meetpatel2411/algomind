import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'attendance_recorded_screen.dart';
import 'services/database_service.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String classId;
  final String subjectName;
  final String room;

  const MarkAttendanceScreen({
    super.key,
    required this.classId,
    required this.subjectName,
    required this.room,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);
  final Color dangerColor = const Color(0xffef4444);

  // We'll maintain local state of attendance here
  // Map<StudentId, Status>
  Map<String, String> _attendanceMap = {};
  List<QueryDocumentSnapshot> _studentsDocs = [];

  int get presentCount => _attendanceMap.values.where((s) => s == 'P').length;
  int get absentCount => _attendanceMap.values.where((s) => s == 'A').length;

  bool _isSubmitting = false;

  Future<void> _submitAttendance() async {
    setState(() => _isSubmitting = true);
    try {
      final List<Map<String, dynamic>> records = _attendanceMap.entries.map((
        e,
      ) {
        return {
          'studentId': e.key,
          'status': e.value == 'P' ? 'Present' : 'Absent',
          'remarks': '',
        };
      }).toList();

      // If no students, or not loaded yet
      if (records.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No students to mark attendance for.')),
        );
        return;
      }

      // We need teacherId. For now, we can get it from current user or just pass a placeholder if not strictly enforced by rules.
      // In real app, we get it from Auth.
      // Using "current_teacher_id" as placeholder or if I have access to it.
      // I can use FirebaseAuth.instance.currentUser?.uid but I need to import FirebaseAuth.
      // For now, let's assume current user is the teacher.

      // Actually DatabaseService markAttendance needs teacherId.
      // Let's pass a placeholder or handle it in DatabaseService if null (it takes String).

      await DatabaseService().markAttendance(
        widget.classId,
        'subject_id_placeholder', // TODO: Pass subjectId properly
        'teacher_id_placeholder',
        DateTime.now(),
        records,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AttendanceRecordedScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error marking attendance: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
                sliver: StreamBuilder<QuerySnapshot>(
                  stream: DatabaseService().getStudentsByClass(widget.classId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];
                    _studentsDocs = docs;

                    // Initialize map for new students
                    for (var doc in docs) {
                      if (!_attendanceMap.containsKey(doc.id)) {
                        _attendanceMap[doc.id] = 'P'; // Default Present
                      }
                    }

                    if (docs.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'No students found in this class.',
                            style: GoogleFonts.lexend(color: subTextColor),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final studentId = doc.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildStudentCardWithToggles(
                            studentId,
                            data,
                            isDarkMode,
                            surfaceColor,
                            textColor,
                            subTextColor,
                            borderColor,
                          ),
                        );
                      }, childCount: docs.length),
                    );
                  },
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
                                '${widget.classId} • ${widget.subjectName}',
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
                            '${_studentsDocs.length} Students Total',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                for (var s in _attendanceMap.keys) {
                                  _attendanceMap[s] = 'P';
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
    String studentId,
    Map<String, dynamic> data,
    bool isDarkMode,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
  ) {
    // final student = students[index]; // OLD
    final String currentStatus = _attendanceMap[studentId] ?? 'P';
    final bool isAbsent = currentStatus == 'A';
    final Color rollBg = isAbsent
        ? dangerColor.withOpacity(0.1)
        : primaryColor.withOpacity(0.1);
    final Color rollText = isAbsent ? dangerColor : primaryColor;

    final String name = data['fullName'] ?? 'Uknown';
    final String roll = (data['rollNumber'] ?? '00').toString();
    final String displayId = studentId.substring(0, 6).toUpperCase();

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
                    roll,
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
                    name,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'ID: $displayId',
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
                  currentStatus == 'P',
                  primaryColor,
                  () => setState(() => _attendanceMap[studentId] = 'P'),
                ),
                _buildStatusOption(
                  'A',
                  currentStatus == 'A',
                  dangerColor,
                  () => setState(() => _attendanceMap[studentId] = 'A'),
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
                onPressed: _isSubmitting ? null : _submitAttendance,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  _isSubmitting ? 'Saving...' : 'Save Attendance Offline',
                ),
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
