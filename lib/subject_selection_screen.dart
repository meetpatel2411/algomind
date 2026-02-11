import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'subject_details_screen.dart';
import 'enrolled_courses_screen.dart';
import 'student_dashboard.dart';

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);

  int _selectedIndex = 1; // Learn is active

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
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(
                  textColor,
                  subTextColor,
                  surfaceColor,
                  borderColor,
                  isDarkMode,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                          children: [
                            _buildSubjectCard(
                              context,
                              'Mathematics',
                              '12 Chapters',
                              Icons.functions_rounded,
                              primaryColor,
                              0.65,
                              'Mathematics is the universal language used to describe the world. This course covers everything from basic algebra to advanced calculus.',
                              [
                                {
                                  'number': '1',
                                  'title': 'Linear Algebra',
                                  'subtitle': '8 Lessons',
                                  'status': 'completed',
                                  'time': '45 mins',
                                  'marks': '50 Marks',
                                },
                                {
                                  'number': '2',
                                  'title': 'Calculus I',
                                  'subtitle': '12 Lessons',
                                  'status': 'completed',
                                  'time': '60 mins',
                                  'marks': '75 Marks',
                                },
                                {
                                  'number': '3',
                                  'title': 'Trigonometry',
                                  'subtitle': '10 Lessons',
                                  'status': 'inprogress',
                                  'time': '45 mins',
                                  'marks': '50 Marks',
                                },
                                {
                                  'number': '4',
                                  'title': 'Statistics',
                                  'subtitle': '15 Lessons',
                                  'status': 'pending',
                                  'time': '30 mins',
                                  'marks': '40 Marks',
                                },
                              ],
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            _buildSubjectCard(
                              context,
                              'Physics',
                              '10 Chapters',
                              Icons.flare_rounded,
                              Colors.purple,
                              0.42,
                              'Physics explores the fundamental laws of nature, from the smallest particles to the vastness of the cosmos.',
                              [
                                {
                                  'number': '1',
                                  'title': 'Classical Mechanics',
                                  'subtitle': '15 Lessons',
                                  'status': 'completed',
                                  'time': '45 mins',
                                  'marks': '50 Marks',
                                },
                                {
                                  'number': '2',
                                  'title': 'Thermodynamics',
                                  'subtitle': '8 Lessons',
                                  'status': 'inprogress',
                                  'time': '60 mins',
                                  'marks': '100 Marks',
                                },
                                {
                                  'number': '3',
                                  'title': 'Electromagnetism',
                                  'subtitle': '12 Lessons',
                                  'status': 'pending',
                                  'time': '45 mins',
                                  'marks': '50 Marks',
                                },
                              ],
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            _buildSubjectCard(
                              context,
                              'Chemistry',
                              '8 Chapters',
                              Icons.science_rounded,
                              Colors.amber,
                              0.88,
                              'Chemistry is the study of matter, its properties, and how it changes through chemical reactions.',
                              [
                                {
                                  'number': '1',
                                  'title': 'Atomic Structure',
                                  'subtitle': '6 Lessons',
                                  'status': 'completed',
                                  'time': '30 mins',
                                  'marks': '30 Marks',
                                },
                                {
                                  'number': '2',
                                  'title': 'Chemical Bonding',
                                  'subtitle': '10 Lessons',
                                  'status': 'completed',
                                  'time': '45 mins',
                                  'marks': '50 Marks',
                                },
                                {
                                  'number': '3',
                                  'title': 'Organic Chemistry',
                                  'subtitle': '20 Lessons',
                                  'status': 'inprogress',
                                  'time': '90 mins',
                                  'marks': '150 Marks',
                                },
                              ],
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            _buildSubjectCard(
                              context,
                              'Biology',
                              '14 Chapters',
                              Icons.biotech_rounded,
                              Colors.green,
                              0.20,
                              'Biology is the science of life, exploring organisms, their structures, and evolutionary processes.',
                              [
                                {
                                  'number': '1',
                                  'title': 'Cell Biology',
                                  'subtitle': '10 Lessons',
                                  'status': 'completed',
                                  'time': '45 mins',
                                  'marks': '50 Marks',
                                },
                                {
                                  'number': '2',
                                  'title': 'Genetics',
                                  'subtitle': '15 Lessons',
                                  'status': 'inprogress',
                                  'time': '60 mins',
                                  'marks': '100 Marks',
                                },
                                {
                                  'number': '3',
                                  'title': 'Ecology',
                                  'subtitle': '12 Lessons',
                                  'status': 'pending',
                                  'time': '30 mins',
                                  'marks': '40 Marks',
                                },
                              ],
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            _buildSubjectCard(
                              context,
                              'English',
                              '15 Chapters',
                              Icons.auto_stories_rounded,
                              const Color(0xfff43f5e),
                              0.0,
                              'Enhance your communication skills through literature analysis, creative writing, and advanced grammar.',
                              [
                                {
                                  'number': '1',
                                  'title': 'Literature Basics',
                                  'subtitle': '12 Lessons',
                                  'status': 'pending',
                                  'time': '45 mins',
                                  'marks': '50 Marks',
                                },
                                {
                                  'number': '2',
                                  'title': 'Creative Writing',
                                  'subtitle': '8 Lessons',
                                  'status': 'pending',
                                  'time': '30 mins',
                                  'marks': '40 Marks',
                                },
                              ],
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            _buildSubjectCard(
                              context,
                              'History',
                              '6 Chapters',
                              Icons.history_edu_rounded,
                              Colors.blueGrey,
                              0.10,
                              'Discover the pivotal events and figures that have shaped our world through the ages.',
                              [
                                {
                                  'number': '1',
                                  'title': 'Ancient Civilizations',
                                  'subtitle': '10 Lessons',
                                  'status': 'inprogress',
                                  'time': '60 mins',
                                  'marks': '100 Marks',
                                },
                                {
                                  'number': '2',
                                  'title': 'The Middle Ages',
                                  'subtitle': '8 Lessons',
                                  'status': 'pending',
                                  'time': '45 mins',
                                  'marks': '50 Marks',
                                },
                              ],
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Subject',
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                'Academic Year 2024-25',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff10b981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xff10b981).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sync_rounded,
                  size: 16,
                  color: Color(0xff10b981),
                ),
                const SizedBox(width: 6),
                Text(
                  'OFFLINE READY',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff10b981),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    String title,
    String chaptersStr,
    IconData icon,
    Color color,
    double progress,
    String description,
    List<Map<String, String>> chapters,
    bool isDarkMode,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailsScreen(
              title: title,
              icon: icon,
              color: color,
              progress: progress,
              description: description,
              chapters: chapters,
            ),
          ),
        );
      },
      child: Container(
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
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 30),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chaptersStr,
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        color: subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PROGRESS',
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: subTextColor.withValues(alpha: 0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        color: surfaceColor.withValues(alpha: 0.95),
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
            color: isSelected ? primaryColor : subTextColor.withValues(alpha: 0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? primaryColor : subTextColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
