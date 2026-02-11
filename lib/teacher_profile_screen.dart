import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database_service.dart';
import 'widgets/profile_image.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';

class TeacherProfileScreen extends StatefulWidget {
  final String? uid;
  const TeacherProfileScreen({super.key, this.uid});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);

  int _selectedTabIndex = 0;
  final DatabaseService _db = DatabaseService();
  late final String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) return const SizedBox();

          // Prepare teacher data
          final Map<String, String> teacherData = {
            'name': userData['fullName'] ?? 'Teacher',
            'image': userData['imageUrl'] ?? '',
            'role': userData['role'] ?? 'Teacher',
            'email': userData['email'] ?? 'No Email',
            'specialization': userData['specialization'] ?? 'General',
          };

          return SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    _buildHeader(isDarkMode, textColor, subTextColor),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _buildSummaryCard(
                              teacherData,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            const SizedBox(height: 24),
                            _buildMetricsGrid(
                              _uid!,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                              isDarkMode,
                            ),
                            const SizedBox(height: 24),
                            _buildTabbedRecords(
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                              isDarkMode,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      color: subTextColor,
                      size: 24,
                    ),
                    Text(
                      'Back',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xff10b981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(uid: _uid!),
                        ),
                      );
                    },
                    icon: Icon(Icons.settings_rounded, color: subTextColor),
                  ),
                  IconButton(
                    onPressed: () async {
                      final userData = await _db.getUserProfile(_uid!);
                      if (!context.mounted) return;
                      if (userData != null) {
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              userData: userData,
                              uid: _uid,
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.edit_note_rounded, color: primaryColor),
                    tooltip: 'Edit Profile',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    Map<String, String> data,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileImage(
            imageUrl: data['image'] ?? '',
            size: 96,
            borderColor: Colors.white,
            borderWidth: 4,
          ),
          const SizedBox(height: 16),
          Text(
            data['name'] ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            data['email'] ?? '',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data['role']?.toUpperCase() ?? 'TEACHER',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
    String uid,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return StreamBuilder<int>(
      stream: _db.getAllStudentsCount(),
      builder: (context, studentsSnapshot) {
        final totalStudents = studentsSnapshot.data ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: _db.getTeacherClasses(uid),
          builder: (context, classesSnapshot) {
            final totalClasses = classesSnapshot.data?.docs.length ?? 0;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                // Total Students
                _buildStatItem(
                  totalStudents.toString(),
                  'Total Students',
                  Icons.groups_rounded,
                  surfaceColor,
                  borderColor,
                  textColor,
                  subTextColor,
                  const Color(0xff10b981),
                ),
                // Total Classes
                _buildStatItem(
                  totalClasses.toString(),
                  'Classes Taught',
                  Icons.class_rounded,
                  surfaceColor,
                  borderColor,
                  textColor,
                  subTextColor,
                  primaryColor,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 24, // Consistent large font for numbers
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
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

  Widget _buildTabbedRecords(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Tabs
          Row(
            children: [
              _buildTab('Classes', 0, textColor, subTextColor),
              _buildTab('Exams', 1, textColor, subTextColor),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: _selectedTabIndex == 0
                ? _buildClassesList(textColor, subTextColor, isDarkMode)
                : _buildExamsList(textColor, subTextColor, isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    String label,
    int index,
    Color textColor,
    Color subTextColor,
  ) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? primaryColor
                  : subTextColor.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassesList(
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getTeacherClasses(_uid!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return Text(
            "No classes assigned.",
            style: GoogleFonts.lexend(color: subTextColor),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildListItem(
                data['name'] ?? 'Class',
                '${data['section'] ?? ''} • ${data['room'] ?? 'Room'}',
                Icons.class_rounded,
                primaryColor,
                isDarkMode,
                textColor,
                subTextColor,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildExamsList(Color textColor, Color subTextColor, bool isDarkMode) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getExamsForTeacher(_uid!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return Text(
            "No exams created.",
            style: GoogleFonts.lexend(color: subTextColor),
          );
        }

        return Column(
          children: snapshot.data!.docs.take(5).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildListItem(
                data['title'] ?? 'Exam',
                data['subjectName'] ?? 'General',
                Icons.assignment_rounded,
                const Color(0xffea580c),
                isDarkMode,
                textColor,
                subTextColor,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildListItem(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool isDarkMode,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black26 : const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white10 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.lexend(fontSize: 12, color: subTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
