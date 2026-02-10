import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                              'Mathematics',
                              '12 Chapters',
                              Icons.functions_rounded,
                              primaryColor,
                              0.65,
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            _buildSubjectCard(
                              'Physics',
                              '10 Chapters',
                              Icons.flare_rounded,
                              Colors.purple,
                              0.42,
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            _buildSubjectCard(
                              'Chemistry',
                              '8 Chapters',
                              Icons.science_rounded,
                              Colors.amber,
                              0.88,
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            _buildSubjectCard(
                              'Biology',
                              '14 Chapters',
                              Icons.biotech_rounded,
                              Colors.green,
                              0.20,
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            _buildSubjectCard(
                              'English',
                              '15 Chapters',
                              Icons.auto_stories_rounded,
                              const Color(0xfff43f5e),
                              0.0,
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                            _buildSubjectCard(
                              'History',
                              '6 Chapters',
                              Icons.history_edu_rounded,
                              Colors.blueGrey,
                              0.10,
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
              color: const Color(0xff10b981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xff10b981).withOpacity(0.2),
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
    String title,
    String chapters,
    IconData icon,
    Color color,
    double progress,
    bool isDarkMode,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
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
                      color: color.withOpacity(0.1),
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
                    chapters,
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
                        color: subTextColor.withOpacity(0.6),
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
          _buildNavItem(Icons.local_library_rounded, 'Learn', 1, subTextColor),
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
    return Column(
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
            fontWeight: FontWeight.bold,
            color: isSelected ? primaryColor : subTextColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
