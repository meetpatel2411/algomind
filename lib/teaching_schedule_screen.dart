import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'services/database_service.dart';
import 'widgets/teacher_bottom_navigation.dart';
import 'add_edit_class_screen.dart';
import 'mark_attendance_screen.dart';
import 'widgets/profile_image.dart';
import 'teacher_profile_screen.dart';

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

  DateTime _selectedDate = DateTime.now();
  // int _selectedNavItem = 2; // Removed unused variable // Schedule

  late AnimationController _pulseController;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

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
                // _buildSystemStatusBar(isDarkMode, subTextColor), // Removed
                _buildHeader(textColor, subTextColor, isDarkMode),
                _buildDateSelector(
                  textColor,
                  subTextColor,
                  surfaceColor,
                  borderColor,
                  isDarkMode,
                ),
                _buildAddClassButton(),
                Expanded(
                  child: _buildClassesList(
                    surfaceColor,
                    borderColor,
                    textColor,
                    subTextColor,
                    isDarkMode,
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
            // _buildSyncIndicator(), // Removed in favor of global bottom bar
          ],
        ),
      ),
    );
  }

  // Removed _buildSystemStatusBar

  Widget _buildHeader(Color textColor, Color subTextColor, bool isDarkMode) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
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
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final userData =
                      snapshot.data?.data() as Map<String, dynamic>?;
                  final String imageUrl =
                      userData?['imageUrl'] ??
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDDJ0xT_gismssEV3tDJT-5kYdGVXCrGNSCNKwmxu_icHAUrDUt8owJFEtSDe1qLPCXqxnROGnBHSIZ7GH-U6H3SMmGMkkJ1Ca6uCEO3HwTYcwMyyMIJgaAd-70rgAIsHbISjIG4SRNf8H5PQc0evW9-XY5d2A7fH_stOAZUy-RyDk09YD-JA16RkWy6use7JvQlpOkiNWqQ2cyujIfT8bjohE5T6AytBDjzLWE68a6BXk7LCzNDZd-p632NC373yt71pGpNoehdYk';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeacherProfileScreen(uid: uid),
                        ),
                      );
                    },
                    child: ProfileImage(
                      imageUrl: imageUrl,
                      size: 40,
                      borderColor: primaryColor.withValues(alpha: 0.2),
                      borderWidth: 2,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down_rounded, color: subTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAddClassButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditClassScreen()),
          );
        },
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'Add Class',
          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
    final String teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getTeacherClassesByDate(
        teacherId,
        _selectedDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading classes',
              style: GoogleFonts.lexend(color: subTextColor),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final classes = snapshot.data?.docs ?? [];

        if (classes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No classes scheduled for today',
                style: GoogleFonts.lexend(color: subTextColor, fontSize: 16),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 120,
            left: 24,
            right: 24,
            top: 16,
          ),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final data = classes[index].data() as Map<String, dynamic>;
            final className = data['className'] ?? data['name'] ?? 'Class';
            final subject = data['subjectName'] ?? data['subject'] ?? 'Subject';
            final section = data['section'] ?? '';

            final room = data['room'] ?? 'Room';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditClassScreen(
                        classId: classes[index].id,
                        classData: data,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject,
                                  style: GoogleFonts.lexend(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$className${section.isNotEmpty ? " • $section" : ""}',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xff334155)
                                  : const Color(0xfff1f5f9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              room,
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: subTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: subTextColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${data['startTime'] ?? 'N/A'} - ${data['endTime'] ?? 'N/A'}',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Mark Attendance Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MarkAttendanceScreen(
                                  subjectId:
                                      data['subjectId'] ?? 'unknown_subject',
                                  teacherId: teacherId,
                                  classId: data['classId'] ?? classes[index].id,
                                  className: className,
                                  subjectName: subject,
                                  date: _selectedDate,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: Text(
                            'Mark Attendance',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: successColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNav(
    Color surfaceColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return TeacherBottomNavigation(currentIndex: 3, isDarkMode: isDarkMode);
  }

  // Removed _buildSyncIndicator
}
