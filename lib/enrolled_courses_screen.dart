import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/profile_image.dart';
import 'widgets/student_bottom_navigation.dart';
import 'course_details_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'models/subject.dart'; // Removed as not used
import 'services/database_service.dart';
import 'widgets/connectivity_indicator.dart';

class EnrolledCoursesScreen extends StatefulWidget {
  final String? uid;
  const EnrolledCoursesScreen({super.key, this.uid});

  @override
  State<EnrolledCoursesScreen> createState() => _EnrolledCoursesScreenState();
}

class _EnrolledCoursesScreenState extends State<EnrolledCoursesScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color secondaryGreen = const Color(0xff10b981);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
      body: ConnectivityIndicator(
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  _buildHeader(
                    surfaceColor,
                    textColor,
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

                        return StreamBuilder<QuerySnapshot>(
                          stream: DatabaseService().getSubjects(classId),
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

                            final allSubjects = snapshot.data!.docs;
                            final subjects = _searchQuery.isEmpty
                                ? allSubjects
                                : allSubjects.where((doc) {
                                    final name =
                                        (doc.data()
                                                as Map<String, dynamic>)['name']
                                            ?.toString()
                                            .toLowerCase() ??
                                        "";
                                    return name.contains(
                                      _searchQuery.toLowerCase(),
                                    );
                                  }).toList();

                            if (subjects.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.library_books_rounded,
                                      size: 64,
                                      color: subTextColor.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No courses found.',
                                      style: GoogleFonts.lexend(
                                        fontSize: 16,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                24,
                                16,
                                120,
                              ),
                              child: Center(
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 500,
                                  ),
                                  child: Column(
                                    children: subjects.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      final title =
                                          data['name'] ?? 'Unknown Subject';
                                      // Mock data for missing fields
                                      const progress = 0.35;
                                      const instructor = 'Course Instructor';
                                      const instructorImg =
                                          'https://ui-avatars.com/api/?name=Instructor&background=random';

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        child: _buildCourseCard(
                                          status: 'In Progress',
                                          title: title,
                                          progress: progress,
                                          instructor: instructor,
                                          instructorImg: instructorImg,
                                          badge: 'ONLINE',
                                          actionText: 'OPEN',
                                          isDarkMode: isDarkMode,
                                          surfaceColor: surfaceColor,
                                          textColor: textColor,
                                          subTextColor: subTextColor,
                                          borderColor: borderColor,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              _buildStickyToast(isDarkMode),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StudentBottomNavigation(
                  currentIndex: 1,
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

  Widget _buildHeader(
    Color surfaceColor,
    Color textColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.8),
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
                  color: secondaryGreen.withValues(alpha: 0.1),
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
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
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
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
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
            color: Colors.black.withValues(alpha: 0.02),
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
                            ? primaryColor.withValues(alpha: 0.1)
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
                        ProfileImage(imageUrl: instructorImg, size: 24),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CourseDetailsScreen(title: title),
                          ),
                        );
                      },
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
                color: Colors.black.withValues(alpha: 0.2),
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
}
