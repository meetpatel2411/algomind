import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';
import 'widgets/profile_image.dart';
import 'widgets/teacher_bottom_navigation.dart';

class StudentEvaluationScreen extends StatefulWidget {
  const StudentEvaluationScreen({super.key});

  @override
  State<StudentEvaluationScreen> createState() =>
      _StudentEvaluationScreenState();
}

class _StudentEvaluationScreenState extends State<StudentEvaluationScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);
  final Color errorColor = const Color(0xffef4444);
  final Color warningColor = const Color(0xfff59e0b);

  final DatabaseService _db = DatabaseService();
  String? _selectedClassId;
  // String _selectedClassName = 'Select Class'; // Corrected: Unused
  List<DocumentSnapshot> _classes = [];
  bool _isLoadingClasses = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _db.getTeacherClasses(uid).listen((snapshot) {
        if (mounted) {
          setState(() {
            _classes = snapshot.docs;
            if (_classes.isNotEmpty && _selectedClassId == null) {
              _selectedClassId = _classes.first.id;
              // _selectedClassName = _classes.first['name'];
            }
            _isLoadingClasses = false;
          });
        }
      });
    } else {
      if (mounted) setState(() => _isLoadingClasses = false);
    }
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(
                  context,
                  textColor,
                  subTextColor,
                  surfaceColor,
                  borderColor,
                  primaryColor,
                ),
                Expanded(
                  child: _selectedClassId == null
                      ? Center(
                          child: _isLoadingClasses
                              ? const CircularProgressIndicator()
                              : Text(
                                  'No classes found',
                                  style: GoogleFonts.lexend(
                                    color: subTextColor,
                                  ),
                                ),
                        )
                      : StreamBuilder<QuerySnapshot>(
                          stream: _db.getStudentsByClass(_selectedClassId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  'No students in this class',
                                  style: GoogleFonts.lexend(
                                    color: subTextColor,
                                  ),
                                ),
                              );
                            }

                            final students = snapshot.data!.docs;

                            return SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                24,
                                24,
                                100,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Summary stats could be calculated here by iterating all students
                                  // For now, we'll keep them as placeholders or simple counts
                                  _buildSummaryStats(
                                    surfaceColor,
                                    borderColor,
                                    subTextColor,
                                    textColor,
                                    students.length, // Pass total count
                                  ),
                                  const SizedBox(height: 32),
                                  _buildListControls(
                                    primaryColor,
                                    subTextColor,
                                    students.length,
                                  ),
                                  const SizedBox(height: 16),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: students.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      return _buildStudentCard(
                                        students[index],
                                        surfaceColor,
                                        borderColor,
                                        textColor,
                                        subTextColor,
                                        isDarkMode,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFooter(
              context,
              surfaceColor,
              borderColor,
              primaryColor,
              isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24, top: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xff101722).withValues(alpha: 0.8)
            : const Color(0xfff6f7f8).withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: primaryColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
              ),
              // Class Dropdown
              DropdownButton<String>(
                value: _selectedClassId,
                underline: const SizedBox(),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: primaryColor,
                ),
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                dropdownColor: surfaceColor,
                items: _classes.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(data['name'] ?? 'Class'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedClassId = val;
                      /* _selectedClassName = _classes.firstWhere(
                        (c) => c.id == val,
                      )['name']; */
                    });
                  }
                },
                hint: Text(
                  'Select Class',
                  style: TextStyle(color: subTextColor),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.sync_rounded, color: primaryColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              style: GoogleFonts.lexend(fontSize: 14, color: textColor),
              decoration: InputDecoration(
                hintText: 'Search student name...',
                hintStyle: GoogleFonts.lexend(
                  color: subTextColor.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: subTextColor.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(
    Color surfaceColor,
    Color borderColor,
    Color subTextColor,
    Color textColor,
    int totalStudents,
  ) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL STUDENTS',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalStudents.toString(),
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PASS RATE',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '--%', // Dynamic calculation requires improved queries
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: successColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 4),
                    child: Icon(
                      Icons.trending_up,
                      color: successColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListControls(Color primaryColor, Color subTextColor, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'RESULTS ($count)',
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: subTextColor,
            letterSpacing: 1.5,
          ),
        ),
        Row(
          children: [
            Icon(Icons.tune_rounded, color: primaryColor, size: 16),
            const SizedBox(width: 4),
            Text(
              'Filter',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentCard(
    DocumentSnapshot studentDoc,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    final data = studentDoc.data() as Map<String, dynamic>;
    final String name = data['name'] ?? data['fullName'] ?? 'Student';
    final String id = data['studentId'] ?? data['rollNumber'] ?? 'N/A';
    final String imageUrl =
        data['imageUrl'] ??
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDDJ0xT_gismssEV3tDJT-5kYdGVXCrGNSCNKwmxu_icHAUrDUt8owJFEtSDe1qLPCXqxnROGnBHSIZ7GH-U6H3SMmGMkkJ1Ca6uCEO3HwTYcwMyyMIJgaAd-70rgAIsHbISjIG4SRNf8H5PQc0evW9-XY5d2A7fH_stOAZUy-RyDk09YD-JA16RkWy6use7JvQlpOkiNWqQ2cyujIfT8bjohE5T6AytBDjzLWE68a6BXk7LCzNDZd-p632NC373yt71pGpNoehdYk';

    // Fetch Avg Score real-time
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getStudentExamResults(studentDoc.id),
      builder: (context, snapshot) {
        String scoreDisplay = '--';
        String status = 'N/A';
        bool isFail = false;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final results = snapshot.data!.docs;
          double total = 0;
          int count = 0;

          for (var res in results) {
            final rData = res.data() as Map<String, dynamic>;
            final marks = rData['marksObtained'];
            if (marks != null) {
              total += (marks as num).toDouble();
              count++;
            }
          }

          if (count > 0) {
            double avg = total / count;
            scoreDisplay = avg.toStringAsFixed(1);
            isFail = avg < 40; // Simple logic
            status = isFail ? 'Fail' : 'Pass';
          }
        }

        final Color scoreColor = isFail ? errorColor : textColor;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: isFail ? 0.9 : 1.0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ProfileImage(
                        imageUrl: imageUrl,
                        size: 48,
                        borderColor: isFail
                            ? errorColor.withValues(alpha: 0.2)
                            : primaryColor.withValues(alpha: 0.2),
                        borderWidth: 2,
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
                            'ID: $id',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        scoreDisplay,
                        style: GoogleFonts.lexend(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        'Avg Score',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDarkMode
                          ? borderColor.withValues(alpha: 0.5)
                          : const Color(0xfff8fafc),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildStatusBadge(
                          status,
                          isFail
                              ? Icons.error_outline_rounded
                              : Icons.check_circle_rounded,
                          isFail ? errorColor : successColor,
                          isDarkMode,
                        ),
                      ],
                    ),
                    if (isFail)
                      Row(
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            color: warningColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          _buildViewFeedbackButton(primaryColor),
                        ],
                      )
                    else
                      _buildViewFeedbackButton(primaryColor),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(
    String label,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    Color bgColor = color.withValues(alpha: isDarkMode ? 0.2 : 0.1);
    if (label == 'Pass') {
      bgColor = isDarkMode
          ? const Color(0xff064e3b).withValues(alpha: 0.4)
          : const Color(0xffd1fae5);
    }
    if (label == 'Fail') {
      bgColor = isDarkMode
          ? const Color(0xff881337).withValues(alpha: 0.4)
          : const Color(0xffffe4e6);
    }
    if (label == 'N/A') bgColor = Colors.grey.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: label == 'N/A' ? Colors.grey : color),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: label == 'N/A' ? Colors.grey : color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewFeedbackButton(Color primaryColor) {
    return Row(
      children: [
        Text(
          'VIEW FEEDBACK',
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: primaryColor, size: 16),
      ],
    );
  }

  Widget _buildFooter(
    BuildContext context,
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 4,
                shadowColor: primaryColor.withValues(alpha: 0.25),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.file_download_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'EXPORT CLASS RESULTS',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TeacherBottomNavigation(
            currentIndex: 1, // Highlighting Students tab
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}
