import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'services/database_service.dart';
import 'widgets/teacher_bottom_navigation.dart';
import 'mark_attendance_screen.dart';
import 'widgets/profile_image.dart';
import 'teacher_profile_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);
  final Color dangerColor = const Color(0xffef4444);
  final Color warningColor = const Color(0xfff59e0b);

  DateTime _selectedDate = DateTime.now();
  final DatabaseService _db = DatabaseService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  // int _selectedIndex = 3; // Removed unused variable

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
        child: Column(
          children: [
            _buildHeader(textColor, subTextColor, surfaceColor, isDarkMode),
            TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: subTextColor,
              indicatorColor: primaryColor,
              labelStyle: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: 'Mark Attendance'),
                Tab(text: 'History'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMarkAttendanceTab(
                    isDarkMode,
                    textColor,
                    subTextColor,
                    surfaceColor,
                    borderColor,
                  ),
                  _buildHistoryTab(
                    isDarkMode,
                    textColor,
                    subTextColor,
                    surfaceColor,
                    borderColor,
                  ),
                ],
              ),
            ),
            _buildBottomNav(surfaceColor, subTextColor, isDarkMode),
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
              // Back button
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode
                          ? const Color(0xff334155)
                          : const Color(0xffe2e8f0),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: textColor,
                  ),
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
          // Profile icon instead of synced indicator
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final String imageUrl =
                  userData?['imageUrl'] ??
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDDJ0xT_gismssEV3tDJT-5kYdGVXCrGNSCNKwmxu_icHAUrDUt8owJFEtSDe1qLPCXqxnROGnBHSIZ7GH-U6H3SMmGMkkJ1Ca6uCEO3HwTYcwMyyMIJgaAd-70rgAIsHbISjIG4SRNf8H5PQc0evW9-XY5d2A7fH_stOAZUy-RyDk09YD-JA16RkWy6use7JvQlpOkiNWqQ2cyujIfT8bjohE5T6AytBDjzLWE68a6BXk7LCzNDZd-p632NC373yt71pGpNoehdYk';

              return GestureDetector(
                onTap: () {
                  String? uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherProfileScreen(uid: uid),
                      ),
                    );
                  }
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
    );
  }

  Widget _buildAttendanceSummary(bool isDarkMode) {
    // Recalculate colors locally since they aren't passed
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
    return Container(
      padding: const EdgeInsets.all(24),
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
                  color: successColor.withValues(alpha: 0.1),
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

  Widget _buildDatePicker(
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: primaryColor),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

  Widget _buildClassesList(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    // For now, fetching all classes as mock since we don't have real schedule-date mapping in DB yet
    // In a real app, we'd query classes scheduled for this day
    return StreamBuilder(
      stream: _db.getTeacherClasses(
        FirebaseAuth.instance.currentUser?.uid ?? '',
      ), // Assuming auth not fully hooked up with ID yet
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var classes = snapshot.data!.docs;

        if (classes.isEmpty) {
          return Center(
            child: Text(
              'No classes scheduled for today',
              style: GoogleFonts.lexend(color: subTextColor),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            var data = classes[index].data() as Map<String, dynamic>;
            String className = data['name'] ?? 'Class';
            String subject = data['subject'] ?? 'Subject';
            String time = '09:00 AM - 10:00 AM'; // Mock time

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarkAttendanceScreen(
                        subjectId: data['subjectId'] ?? 'unknown_subject',
                        teacherId: FirebaseAuth.instance.currentUser?.uid ?? '',
                        classId: data['classId'] ?? classes[index].id,
                        className: className,
                        subjectName: subject,
                        date: _selectedDate,
                      ),
                    ),
                  );
                },
                child: Container(
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
                            time,
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: subTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subject,
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            className,
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: primaryColor,
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
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Mark',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
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

  // Removed _buildCalendarCard, _buildStatsGrid, _buildOfflineSyncCard helper methods
  // and corresponding logic as we are focusing on daily attendance marking view

  Widget _buildBottomNav(
    Color surfaceColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return TeacherBottomNavigation(currentIndex: 2, isDarkMode: isDarkMode);
  }

  // Removed _buildNavItem as it is now in TeacherBottomNavigation

  // Mark Attendance Tab Content
  Widget _buildMarkAttendanceTab(
    bool isDarkMode,
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAttendanceSummary(isDarkMode),
            const SizedBox(height: 16),
            _buildDatePicker(
              textColor,
              subTextColor,
              surfaceColor,
              borderColor,
            ),
            const SizedBox(height: 16),
            _buildClassesList(
              surfaceColor,
              textColor,
              subTextColor,
              borderColor,
              isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  // History Tab Content
  Widget _buildHistoryTab(
    bool isDarkMode,
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Text(
          'Please login to view history',
          style: GoogleFonts.lexend(color: subTextColor),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _db.getAttendanceHistory(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: dangerColor),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading history',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: subTextColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No attendance history',
                  style: GoogleFonts.lexend(fontSize: 16, color: subTextColor),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final session = snapshot.data!.docs[index];
            final data = session.data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();
            final classId = data['classId'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: _db.classes.doc(classId).get(),
              builder: (context, classSnapshot) {
                if (!classSnapshot.hasData) return const SizedBox.shrink();

                final classData =
                    classSnapshot.data!.data() as Map<String, dynamic>?;
                final className = classData?['name'] ?? 'Unknown Class';
                final subjectName = classData?['subject'] ?? 'Unknown Subject';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
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
                                  className,
                                  style: GoogleFonts.lexend(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subjectName,
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: subTextColor,
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
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              DateFormat('MMM d, yyyy').format(date),
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: subTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('h:mm a').format(date),
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
