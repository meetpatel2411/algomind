import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lesson_preview_screen.dart';
import 'chapter_exam_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String title;
  const CourseDetailsScreen({super.key, this.title = "Advanced Algebra"});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color successColor = const Color(0xff10b981);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);

  bool _isVideoExpanded = true;
  bool _isMaterialsExpanded = false;
  bool _isPracticeExpanded = false;

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
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(
                  surfaceColor,
                  textColor,
                  borderColor,
                  isDarkMode,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      children: [
                        _buildHeroCard(
                          surfaceColor,
                          textColor,
                          subTextColor,
                          borderColor,
                          isDarkMode,
                        ),
                        _buildSyllabusContent(
                          surfaceColor,
                          textColor,
                          subTextColor,
                          borderColor,
                          isDarkMode,
                        ),
                        _buildOfflineBanner(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildBottomActionBar(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    Color surfaceColor,
    Color textColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return SliverAppBar(
      backgroundColor: surfaceColor.withOpacity(0.8),
      elevation: 0,
      pinned: true,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
        color: textColor,
      ),
      title: Text(
        widget.title,
        style: GoogleFonts.lexend(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded),
          onPressed: () {},
          color: textColor,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: borderColor, height: 1),
      ),
    );
  }

  Widget _buildHeroCard(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'IN PROGRESS',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.title}: Mastering Linear Functions',
                  style: GoogleFonts.lexend(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore complex equations, graphing techniques, and real-world applications.',
                  style: GoogleFonts.lexend(fontSize: 14, color: subTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildCircularProgress(0.65, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(double progress, bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: isDarkMode
                ? const Color(0xff1e293b)
                : const Color(0xfff1f5f9),
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSyllabusContent(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildCollapsibleSection(
            icon: Icons.play_circle_outline_rounded,
            title: "Video Lectures",
            subtitle: "4/5 Completed",
            isExpanded: _isVideoExpanded,
            onToggle: () =>
                setState(() => _isVideoExpanded = !_isVideoExpanded),
            content: _buildVideoList(
              textColor,
              subTextColor,
              borderColor,
              isDarkMode,
            ),
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            iconColor: primaryColor,
          ),
          const SizedBox(height: 16),
          _buildCollapsibleSection(
            icon: Icons.description_outlined,
            title: "Study Materials",
            subtitle: "2 Items",
            isExpanded: _isMaterialsExpanded,
            onToggle: () =>
                setState(() => _isMaterialsExpanded = !_isMaterialsExpanded),
            content: _buildMaterialsList(
              textColor,
              subTextColor,
              borderColor,
              isDarkMode,
            ),
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            iconColor: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildCollapsibleSection(
            icon: Icons.psychology_outlined,
            title: "Practice Q&A",
            subtitle: "Locked",
            isExpanded: _isPracticeExpanded,
            onToggle: () =>
                setState(() => _isPracticeExpanded = !_isPracticeExpanded),
            content: _buildPracticeContent(textColor, isDarkMode),
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            iconColor: successColor,
            isLocked: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
    required Color surfaceColor,
    required Color borderColor,
    required Color iconColor,
    bool isLocked = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: surfaceColor.withOpacity(0.5),
              child: Row(
                children: [
                  Icon(icon, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (isLocked)
                        const Icon(
                          Icons.lock_rounded,
                          size: 14,
                          color: Colors.grey,
                        )
                      else
                        Text(
                          subtitle,
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) content,
        ],
      ),
    );
  }

  Widget _buildVideoList(
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        _buildVideoItem(
          "1. Introduction to Variables",
          "12:45 • Available Offline",
          status: "completed",
          textColor: textColor,
          subTextColor: subTextColor,
          borderColor: borderColor,
        ),
        _buildVideoItem(
          "2. Linear Equations Part 1",
          "18:20 • Downloading (45%)",
          status: "current",
          textColor: textColor,
          subTextColor: subTextColor,
          borderColor: borderColor,
        ),
        _buildVideoItem(
          "3. Graphing Intercepts",
          "15:10 • 24.5 MB",
          status: "pending",
          textColor: textColor,
          subTextColor: subTextColor,
          borderColor: borderColor,
        ),
      ],
    );
  }

  Widget _buildVideoItem(
    String title,
    String meta, {
    required String status,
    required Color textColor,
    required Color subTextColor,
    required Color borderColor,
  }) {
    bool isCompleted = status == "completed";
    bool isCurrent = status == "current";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonPreviewScreen(title: title),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCurrent
              ? primaryColor.withOpacity(0.05)
              : Colors.transparent,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? successColor.withOpacity(0.1)
                    : (isCurrent ? primaryColor : Colors.grey.withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check
                    : (isCurrent ? Icons.play_arrow : Icons.play_arrow),
                size: 16,
                color: isCompleted
                    ? successColor
                    : (isCurrent ? Colors.white : Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                      color: isCurrent ? primaryColor : textColor,
                    ),
                  ),
                  Text(
                    meta,
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      color: isCurrent
                          ? primaryColor.withOpacity(0.6)
                          : subTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isCompleted
                  ? Icons.cloud_done
                  : (isCurrent
                        ? Icons.downloading
                        : Icons.file_download_outlined),
              size: 20,
              color: isCompleted
                  ? successColor
                  : (isCurrent ? primaryColor : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList(
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        _buildMaterialItem(
          "Chapter 4 Summary Notes",
          "PDF • 1.2 MB",
          icon: Icons.picture_as_pdf_outlined,
          iconColor: Colors.red,
          textColor: textColor,
          subTextColor: subTextColor,
          borderColor: borderColor,
        ),
        _buildMaterialItem(
          "Lecture Slides: Functions",
          "PPTX • 4.5 MB",
          icon: Icons.slideshow_rounded,
          iconColor: Colors.blue,
          textColor: textColor,
          subTextColor: subTextColor,
          borderColor: borderColor,
        ),
      ],
    );
  }

  Widget _buildMaterialItem(
    String title,
    String meta, {
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color subTextColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                Text(
                  meta,
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    color: subTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.file_download_outlined,
            size: 20,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeContent(Color textColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "All lessons completed. You're ready for the chapter exam!",
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChapterExamScreen(
                      chapterTitle: "Advanced Algebra",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Start Chapter Exam",
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.offline_pin_outlined, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Offline Mode Ready",
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "This course is optimized for offline study. Downloaded content will remain available even when you're off the grid.",
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: primaryColor.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(bool isDarkMode) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              isDarkMode ? backgroundDark : backgroundLight,
              isDarkMode
                  ? backgroundDark.withOpacity(0.9)
                  : backgroundLight.withOpacity(0.9),
              isDarkMode
                  ? backgroundDark.withOpacity(0)
                  : backgroundLight.withOpacity(0),
            ],
          ),
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: primaryColor.withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow_rounded),
              const SizedBox(width: 8),
              Text(
                "Resume: Linear Equations Part 1",
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
