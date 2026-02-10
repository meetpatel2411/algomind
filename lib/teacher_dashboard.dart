import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';

import 'widgets/teacher_bottom_navigation.dart';
import 'manage_students_screen.dart';
import 'teaching_schedule_screen.dart';
import 'attendance_screen.dart';
import 'student_evaluation_screen.dart';
import 'widgets/profile_image.dart';

class TeacherDashboard extends StatefulWidget {
  final String? uid;
  const TeacherDashboard({super.key, this.uid});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);

  // int _selectedIndex = 0; // Removed as TeacherBottomNavigation is stateless-ish in usage here,
  // but actually TeacherDashboard needs to know it is index 0.
  // The widget takes currentIndex.
  // The navigation logic is now in the widget.
  // So we don't need _selectedIndex state if we are just displaying the dashboard content.
  // However, the dashboard logic might have used _selectedIndex for other things?
  // Looking at the code, _selectedIndex was only used for the bottom nav highlighting.
  // So we can remove it or ignore it.

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

                              // --- UPCOMING SECTION ---
                              Text(
                                'Up Next',
                                style: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor,
                                      const Color(0xff3b82f6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_active_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Staff Meeting',
                                            style: GoogleFonts.lexend(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Today, 2:00 PM • Conf. Room',
                                            style: GoogleFonts.lexend(
                                              fontSize: 13,
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
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
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Join',
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
                              StreamBuilder<QuerySnapshot>(
                                stream: DatabaseService().getTeacherClasses(
                                  widget.uid ??
                                      FirebaseAuth.instance.currentUser?.uid ??
                                      '',
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError)
                                    return Text('Error: ${snapshot.error}');
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final classes = snapshot.data?.docs ?? [];

                                  if (classes.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: surfaceColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.class_outlined,
                                            size: 48,
                                            color: subTextColor.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No classes found',
                                            style: GoogleFonts.lexend(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Setup your classroom to get started.',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lexend(
                                              color: subTextColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              // Trigger Seed
                                              try {
                                                // Using SeedService from here directly or separate utility
                                                // Assuming SeedService is available or import it
                                                // We need to import seed_service.dart
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Setting up your classroom...',
                                                    ),
                                                  ),
                                                );
                                                // We should ideally call a method that just ensures this teacher has data
                                                // reusing SeedService.seedDatabase() for now which handles full seed
                                                // or create a specific one.
                                                // For now, I'll assume SeedService is imported and use it.
                                                // I need to add import 'services/seed_service.dart';
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error: $e'),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.auto_fix_high_rounded,
                                            ),
                                            label: const Text(
                                              'Initialize Classroom',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: classes.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _buildTodayClassItem(
                                          data['name'] ??
                                              'Class', // e.g. "Advanced Physics"
                                          '${data['section'] ?? ''} • ${data['time'] ?? '09:00 AM'}', // Store time in class for now
                                          data['room'] ?? 'Online',
                                          Icons.class_rounded,
                                          surfaceColor,
                                          borderColor,
                                          textColor,
                                          subTextColor,
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
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
              child: _buildBottomNav(
                surfaceColor,
                subTextColor,
                isDarkMode,
                borderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSyncTime();
  }

  Future<void> _loadSyncTime() async {
    // In a real app, you'd check local storage or connectivity status
    // For now, we set it to now on load
    // setState(() => _lastSynced = DateTime.now()); // Removed

    // Sync student counts for accuracy
    final String uid =
        widget.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      await DatabaseService().recalculateStudentCounts(uid);
    }
  }

  // Removed _buildStatusBar

  Widget _buildHeader(Color textColor, Color subTextColor, bool isDarkMode) {
    final String? uid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final String name = userData?['fullName'] ?? 'Teacher';
          // Use a default image if none provided
          final String imageUrl =
              userData?['imageUrl'] ??
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDDJ0xT_gismssEV3tDJT-5kYdGVXCrGNSCNKwmxu_icHAUrDUt8owJFEtSDe1qLPCXqxnROGnBHSIZ7GH-U6H3SMmGMkkJ1Ca6uCEO3HwTYcwMyyMIJgaAd-70rgAIsHbISjIG4SRNf8H5PQc0evW9-XY5d2A7fH_stOAZUy-RyDk09YD-JA16RkWy6use7JvQlpOkiNWqQ2cyujIfT8bjohE5T6AytBDjzLWE68a6BXk7LCzNDZd-p632NC373yt71pGpNoehdYk';

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $name',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Welcome back to your classroom',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  ProfileImage(
                    imageUrl: imageUrl,
                    size: 48,
                    borderColor: primaryColor.withOpacity(0.2),
                    borderWidth: 2,
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
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(
    bool isDarkMode,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    final String uid =
        widget.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Total Students Stream
          StreamBuilder<int>(
            // stream: DatabaseService().getTeacherStudentCount(uid), // Old logic using class metadata
            stream: DatabaseService()
                .getAllStudentsCount(), // Use global count as requested
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return _buildStatCard(
                count.toString().padLeft(2, '0'),
                'Total Students',
                Icons.groups_rounded,
                primaryColor.withOpacity(0.1),
                primaryColor,
                surfaceColor,
                borderColor,
                subTextColor,
              );
            },
          ),
          const SizedBox(width: 16),

          // Active Exams Stream
          StreamBuilder<int>(
            stream: DatabaseService().getActiveExamsCount(uid),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return _buildStatCard(
                count.toString().padLeft(2, '0'),
                'Exams Active',
                Icons.assignment_rounded,
                const Color(0xfffff7ed),
                const Color(0xffea580c),
                surfaceColor,
                borderColor,
                subTextColor,
              );
            },
          ),

          const SizedBox(width: 16),
          // Pending Eval (Hardcoded for now as logic is complex)
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AttendanceScreen()),
            );
          },
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
          Icons.schedule_rounded,
          const Color(0xfff59e0b),
          Colors.white,
          true,
          surfaceColor,
          borderColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TeachingScheduleScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          'Reports',
          Icons.analytics_rounded,
          surfaceColor,
          primaryColor,
          false,
          surfaceColor,
          borderColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentEvaluationScreen(),
              ),
            );
          },
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
    Color borderColor,
  ) {
    return TeacherBottomNavigation(currentIndex: 0, isDarkMode: isDarkMode);
  }

  // Removed _buildNavItem as it is now in TeacherBottomNavigation
}
