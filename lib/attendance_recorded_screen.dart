import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class AttendanceRecordedScreen extends StatelessWidget {
  const AttendanceRecordedScreen({super.key});

  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);
  final Color dangerColor = const Color(0xffef4444);

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
        ? const Color(0xff1e293b)
        : const Color(0xfff1f5f9);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusBar(isDarkMode, textColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildSuccessHeader(subTextColor),
                    const SizedBox(height: 32),
                    _buildSessionCard(
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildStatsGrid(
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildRateChart(
                      surfaceColor,
                      borderColor,
                      textColor,
                      subTextColor,
                    ),
                    const SizedBox(height: 24),
                    _buildDetailedListLink(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildFooterActions(surfaceColor, bgColor, context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(bool isDarkMode, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const Row(
            children: [
              Icon(Icons.signal_cellular_alt_rounded, size: 14),
              SizedBox(width: 4),
              Icon(Icons.wifi_off_rounded, size: 14),
              SizedBox(width: 4),
              Icon(Icons.battery_full_rounded, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader(Color subTextColor) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 50,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Attendance Recorded!',
          style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xffd1fae5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 14,
                color: Color(0xff047857),
              ),
              const SizedBox(width: 4),
              Text(
                'Saved offline',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff047857),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Data is stored locally on your device. It will automatically sync once you're back online.",
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: subTextColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallBadge('CLASS SESSION', subTextColor),
              _buildSmallBadge('TODAY', subTextColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '10 - Mathematics',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 14, color: primaryColor),
              const SizedBox(width: 4),
              Text(
                '08:30 AM - 09:45 AM',
                style: GoogleFonts.lexend(fontSize: 14, color: subTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: color.withOpacity(0.6),
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildStatsGrid(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'person',
            '28',
            'Present',
            const Color(0xff10b981),
            surfaceColor,
            borderColor,
            subTextColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            'person_off',
            '04',
            'Absent',
            dangerColor,
            surfaceColor,
            borderColor,
            subTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String icon,
    String value,
    String label,
    Color color,
    Color surfaceColor,
    Color borderColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon == 'person'
                  ? Icons.person_rounded
                  : Icons.person_off_rounded,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
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

  Widget _buildRateChart(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
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
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(68, 68),
                  painter: _RingPainter(
                    percentage: 0.88,
                    primaryColor: primaryColor,
                    trackColor: borderColor,
                  ),
                ),
                Text(
                  '88%',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Rate',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Excellent participation for this morning's session.",
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: subTextColor,
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

  Widget _buildDetailedListLink() {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View Detailed List',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterActions(
    Color surfaceColor,
    Color bgColor,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgColor.withOpacity(0), bgColor],
          stops: const [0, 0.4],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((p) => p.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: primaryColor.withOpacity(0.3),
              ),
              child: Text(
                'Back to Dashboard',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 128,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final Color primaryColor;
  final Color trackColor;

  _RingPainter({
    required this.percentage,
    required this.primaryColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 8.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
