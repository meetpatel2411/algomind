import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_dashboard.dart';
import 'course_details_screen.dart';

class EnrolledCoursesScreen extends StatefulWidget {
  const EnrolledCoursesScreen({super.key});

  @override
  State<EnrolledCoursesScreen> createState() => _EnrolledCoursesScreenState();
}

class _EnrolledCoursesScreenState extends State<EnrolledCoursesScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color secondaryGreen = const Color(0xff10b981);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);

  int _selectedIndex = 1; // Course tab is index 1

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
                _buildHeader(surfaceColor, textColor, borderColor, isDarkMode),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          children: [
                            _buildCourseCard(
                              status: 'In Progress',
                              title: 'Mathematics: Grade 10 Advanced',
                              progress: 0.65,
                              instructor: 'Prof. Sarah Jenkins',
                              instructorImg:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCk-joq4Cmi-Caa6ht4VV7uc5SUgNf0yNMOL3DhOgoqMIytTXg_21IRJCYqR8po0d-vnem80piAyqr0NSM5a-svjbHJR5D1skIB9pSeVN9-r5EPHXweezBvrH3akDpZUJm-HFXRJ-VVMsWDhdAK20aGYAAF1JAEYk7Ohnm_5Vw4-X5Jl4nNcPAoN-oHOFFYxjzmZZWbS8xW8JbcH5DBpvl-X2t4Rp8LTLDWfAe7V5w9PNRoTOblJuk0E5cg-omMYFZWswwMlRuowzU',
                              badge: 'OFFLINE',
                              actionText: 'RESUME',
                              isDarkMode: isDarkMode,
                              surfaceColor: surfaceColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),
                            _buildCourseCard(
                              status: 'Unit 2',
                              title: 'Introduction to Physics',
                              progress: 0.12,
                              instructor: 'Dr. Alan Turing',
                              instructorImg:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA-txbkWYu-CJGS952pp17B4HwkT59kgAs4MyP3QtkML0EnTIkvZaXAfdVxCMtkqIbLN7ueJhEHuqyhhBgTfhDmD770bnYhSSePdCSiyimzvWDwdl_YmKiFkneP2RNPt5OfSPfE0MITNaBXZ62mg3J2BWMQ4Fkc9qGW0_BnCLo3XXxZaqy2bXa8yNx3pPID_6xjZbNHENRA3Qur1kCw1aMgBN3s8B7nHLmSG8VEnaTHF4TDck9kRXTa81NGw22Cx19tNLLqyZ45tYk',
                              badge: 'DOWNLOAD',
                              actionText: 'CONTINUE',
                              isDarkMode: isDarkMode,
                              surfaceColor: surfaceColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),
                            _buildLockedCourseCard(
                              title: 'Organic Chemistry II',
                              requirement: 'Complete Biology 101 to unlock',
                              isDarkMode: isDarkMode,
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                            ),
                            const SizedBox(height: 16),
                            _buildCourseCard(
                              status: 'Final Project',
                              title: 'World History: Modern Era',
                              progress: 0.92,
                              instructor: 'Ms. Elena Rodriguez',
                              instructorImg:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBsLoX0FHSIFMvyJ5adY3ITMNUTy04icyS2EyJeRy4zwF2RcWCvfzhvxzaxbNrTrxs8jBgCYfa6kI7a3wODRPb_hWLTsBPXq24hebRBiBFzG-79sEnJEITo4xSleLXy8FjGrF4GqoWY-CKwrAqyuN7EMI9G7rqUXHC_MLHi3S-bGErcVa-UNGHHbqj38QlS3S9rTRJWO1C1oME46UjWlwNCenik0X9c91x4gUE17xIlQhlBlaThZoBClyjcHxqFxczdkQzeh7eZbQo',
                              badge: 'OFFLINE',
                              actionText: 'FINISH',
                              isDarkMode: isDarkMode,
                              surfaceColor: surfaceColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              borderColor: borderColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildStickyToast(isDarkMode),
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
    Color surfaceColor,
    Color textColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Courses',
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: secondaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_done_rounded,
                      size: 14,
                      color: secondaryGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SYNCED',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: secondaryGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search your courses...',
              hintStyle: GoogleFonts.lexend(
                fontSize: 14,
                color: isDarkMode ? Colors.white30 : Colors.black38,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDarkMode ? Colors.white30 : Colors.black38,
              ),
              filled: true,
              fillColor: isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xfff1f5f9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard({
    required String status,
    required String title,
    required double progress,
    required String instructor,
    required String instructorImg,
    required String badge,
    required String actionText,
    required bool isDarkMode,
    required Color surfaceColor,
    required Color textColor,
    required Color subTextColor,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailsScreen(title: title),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                          Row(
                            children: [
                              Icon(
                                Icons.lock_open_rounded,
                                size: 18,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                status.toUpperCase(),
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badge == 'OFFLINE'
                            ? primaryColor.withOpacity(0.1)
                            : (isDarkMode
                                  ? Colors.white10
                                  : const Color(0xfff1f5f9)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            badge == 'OFFLINE'
                                ? Icons.offline_pin_rounded
                                : Icons.download_for_offline_rounded,
                            size: 14,
                            color: badge == 'OFFLINE'
                                ? primaryColor
                                : (isDarkMode
                                      ? Colors.white30
                                      : Colors.black38),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            badge,
                            style: GoogleFonts.lexend(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badge == 'OFFLINE'
                                  ? primaryColor
                                  : (isDarkMode
                                        ? Colors.white30
                                        : Colors.black38),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Course Progress',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subTextColor,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: secondaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white10
                            : const Color(0xfff1f5f9),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: secondaryGreen,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(instructorImg),
                          backgroundColor: isDarkMode
                              ? Colors.white12
                              : Colors.black12,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          instructor,
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        actionText,
                        style: GoogleFonts.lexend(
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
    );
  }

  Widget _buildLockedCourseCard({
    required String title,
    required String requirement,
    required bool isDarkMode,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : const Color(0xffcbd5e1),
          style: BorderStyle
              .solid, // dashed is not directly supported, using opacity to simulate
        ),
      ),
      child: Opacity(
        opacity: 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_rounded, size: 18, color: subTextColor),
                const SizedBox(width: 8),
                Text(
                  'LOCKED',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  requirement,
                  style: GoogleFonts.lexend(fontSize: 12, color: subTextColor),
                ),
                Text(
                  '0%',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white10 : const Color(0xfff1f5f9),
                borderRadius: BorderRadius.circular(5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.0,
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyToast(bool isDarkMode) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xff0f172a),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xff10b981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'All progress saved offline. Will sync when online.',
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
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
          _buildNavItem(Icons.local_library_rounded, 'Course', 1, subTextColor),
          _buildNavItem(Icons.assignment_rounded, 'Exams', 2, subTextColor),
          _buildNavItem(
            Icons.insert_chart_rounded,
            'Analytics',
            3,
            subTextColor,
          ),
          _buildNavItem(Icons.person_rounded, 'Profile', 4, subTextColor),
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
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentDashboard()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const EnrolledCoursesScreen(),
            ),
          );
        }
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
