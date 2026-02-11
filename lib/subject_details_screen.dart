import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double progress;
  final String description;
  final List<Map<String, String>> chapters;

  const SubjectDetailsScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.progress,
    required this.description,
    required this.chapters,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundLight = const Color(0xfff6f7f8);
    final Color backgroundDark = const Color(0xff101722);
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
            _buildHeader(
              context,
              textColor,
              subTextColor,
              surfaceColor,
              borderColor,
              isDarkMode,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(
                      surfaceColor,
                      textColor,
                      subTextColor,
                      borderColor,
                      isDarkMode,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Chapter-wise Exams',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: chapters
                          .map(
                            (chapter) => _buildExamCard(
                              chapter,
                              isDarkMode,
                              surfaceColor,
                              borderColor,
                              textColor,
                              subTextColor,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}% Completed',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'About the Subject',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.lexend(
              fontSize: 13,
              color: subTextColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressIndicator(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDarkMode) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xff94a3b8),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white10 : const Color(0xfff1f5f9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExamCard(
    Map<String, String> chapter,
    bool isDarkMode,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    final String status = chapter['status'] ?? 'pending';
    bool isLocked =
        status == 'locked' ||
        status == 'pending' && chapter['number'] == '4'; // Mock lock logic
    bool isCompleted = status == 'completed';
    bool isInProgress = status == 'inprogress';

    // Override isLocked for mock demonstration matching HTML
    if (chapter['number'] == '4') isLocked = true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLocked
            ? (isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xfff8fafc))
            : surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isInProgress ? color.withValues(alpha: 0.4) : borderColor,
          width: isInProgress ? 2 : 1,
        ),
        boxShadow: isLocked
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Opacity(
        opacity: isLocked ? 0.7 : 1.0,
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
                          Text(
                            'CHAPTER ${chapter['number']}',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: subTextColor.withValues(alpha: 0.6),
                            ),
                          ),
                          if (!isLocked) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.offline_pin_rounded,
                              size: 16,
                              color: Colors.green.shade500,
                            ),
                          ] else ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.cloud_download_rounded,
                              size: 16,
                              color: subTextColor.withValues(alpha: 0.4),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chapter['title'] ?? 'Unknown Chapter',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLocked
                              ? textColor.withValues(alpha: 0.6)
                              : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 20,
                    ),
                  )
                else if (isInProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'IN PROGRESS',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  )
                else if (isLocked)
                  Icon(
                    Icons.lock_rounded,
                    color: subTextColor.withValues(alpha: 0.4),
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildInfoTag(
                  Icons.timer_outlined,
                  chapter['time'] ?? '45 mins',
                  subTextColor,
                  isLocked,
                ),
                const SizedBox(width: 16),
                _buildInfoTag(
                  Icons.assignment_outlined,
                  chapter['marks'] ?? '50 Marks',
                  subTextColor,
                  isLocked,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildActionButton(status, isDarkMode, subTextColor, isLocked),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(
    IconData icon,
    String text,
    Color subTextColor,
    bool isLocked,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isLocked ? subTextColor.withValues(alpha: 0.4) : subTextColor,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isLocked ? subTextColor.withValues(alpha: 0.4) : subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String status,
    bool isDarkMode,
    Color subTextColor,
    bool isLocked,
  ) {
    final Color primaryColor = color;

    if (isLocked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xffe2e8f0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Locked',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: subTextColor.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    if (status == 'completed') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Text(
            'Review Result',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ),
      );
    } else if (status == 'inprogress') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Resume Exam',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: Center(
          child: Text(
            'Start Exam',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      );
    }
  }
}
