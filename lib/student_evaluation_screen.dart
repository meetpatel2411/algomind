import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/profile_image.dart';

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
  final Color errorColor = const Color(0xffef4444); // rose-500
  final Color warningColor = const Color(0xfff59e0b); // amber-500

  final List<Map<String, dynamic>> _students = [
    {
      'name': 'Alexandria Rivers',
      'id': 'RM-2024-082',
      'score': 94,
      'status': 'Pass',
      'isEligible': true,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAuJB40ACwdGv5GXVeNWDn_nPXtxfutpKgBXE2XaYeCCSerbNF0MVba9tchTBCccxqd9_z2RvW6C6gomhmI03nWr7ZQO6OI6bHqFE9D17-mHzEqKCcxphs8ljmrAbn5_t2dumt5qQ1eEF8S2j6vY9pgUPGQBzhgF_nYjHEMUWPS246AJ7zTygYQISmjlJ1Xj9diV15H6CORL46W4WKhNG77B8jV_OaGpssIiUx4TnDPfumqjjHeEaiACxwa8fAOjGLFBJUxaQ-X-YA',
    },
    {
      'name': 'Marcus Sterling',
      'id': 'RM-2024-114',
      'score': 88,
      'status': 'Pass',
      'isEligible': true,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuACMeRSCrGLqoxG9WaG4YGZn3tY6rbU8_iM2Ezx45kTK77PawlzGTWFF_9CsHFz6E6VSNdvHACD7kQOc53dVSXic17fg9UWhVy-w_0DUP5r0GOHM8ilAR8KL3f60GXvc0aW8OCPFFWvNftgBZuDuoE9pqbcxMwEnBcvcDpLXpFm355kk6rZYYGkJvhn500czrsZHTSD0ecHdrtosFJUk73YxB-SJtN4auhlYOd9WOMXKeoSc06Y40oUoFRoZ0LToT5MrOsPlt64gd4',
    },
    {
      'name': 'Elena Vance',
      'id': 'RM-2024-009',
      'score': 52,
      'status': 'Fail',
      'isEligible': false,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBQQoJROb0i8xGoQjfBOxO5076_vFFkliqh99J3KL-lVG2rffzPwbZmd1PIeSELmizUgzOtuAXP7bpUEPZlcF3A7DG_0NHTMqFla7YZwb-qLUPJ_3_uWnmC80AUWi1pcC-JV0-kwsSjcg-DQ-G3tjd7OHEM8ywIihiqznwZEn1O-GQPuYOSkIhP_aXdg5TK0fQeFR_rIULoXSUjzPfB8ogRFZAbK_Zg7KJQCpVGhr7zliQMErwOloW7vGxbel2TmPbYKFxwTBuzFgI',
    },
    {
      'name': 'Julian Thorne',
      'id': 'RM-2024-121',
      'score': 76,
      'status': 'Pass',
      'isEligible': true,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDn7-NmBiN0R1b72rcZo5Y4K566ZLsiKXCbILjffiXJ3FainlkbgMk4aWduKUuUWoTkhDbhXAVhuyGEAQa6dKSsxF54LeC6UxlwLrC5QLmk0qnMucSQWa1Zshj9ZRnkYF1P2NO3nwbcHXpUU0WCnPeuuDwYPa-SCuPZdMCcu1ezt-dmuCv6OEycqN6_P0sids66COLfQ3nXO75IBFmFa983ZOLbSvVoKjs_bH2PTA1IZfrBb9WkVc34hKQcmoV1YxG6lZss6lBFxaQ',
    },
  ];

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryStats(
                          surfaceColor,
                          borderColor,
                          subTextColor,
                          textColor,
                        ),
                        const SizedBox(height: 32),
                        _buildListControls(primaryColor, subTextColor),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _students.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildStudentCard(
                              _students[index],
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
            ? const Color(0xff101722).withOpacity(0.8)
            : const Color(0xfff6f7f8).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: primaryColor.withOpacity(0.1)),
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
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
              ),
              Text(
                'Student Evaluation',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
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
                  color: Colors.black.withOpacity(0.05),
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
                  color: subTextColor.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: subTextColor.withOpacity(0.5),
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
                color: Colors.black.withOpacity(0.02),
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
                'CLASS AVERAGE',
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
                    '82.4',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      '/100',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: subTextColor,
                      ),
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
                color: Colors.black.withOpacity(0.02),
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
                    '92%',
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

  Widget _buildListControls(Color primaryColor, Color subTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'RESULTS (24)',
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
    Map<String, dynamic> student,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    final bool isFail = student['status'] == 'Fail';
    final Color scoreColor = isFail ? errorColor : textColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(isFail ? 0.9 : 1.0),
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ProfileImage(
                    imageUrl: student['imageUrl'],
                    size: 48,
                    borderColor: isFail
                        ? errorColor.withOpacity(0.2)
                        : primaryColor.withOpacity(0.2),
                    borderWidth: 2,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'ID: ${student['id']}',
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
                    '${student['score']}',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    'Score',
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
                      ? borderColor.withOpacity(0.5)
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
                      isFail ? 'Fail' : 'Pass',
                      isFail
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_rounded,
                      isFail ? errorColor : successColor,
                      isDarkMode,
                    ),
                    if (student['isEligible'] == true) ...[
                      const SizedBox(width: 8),
                      _buildStatusBadge(
                        'Eligible',
                        Icons.card_membership_rounded,
                        primaryColor,
                        isDarkMode,
                        bgOpacity: 0.1,
                      ),
                    ],
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
  }

  Widget _buildStatusBadge(
    String label,
    IconData icon,
    Color color,
    bool isDarkMode, {
    double bgOpacity = 0.1,
  }) {
    // Handling specific opacity for pass/fail to match HTML style
    // HTML uses emerald-100 (light) / emerald-900/30 (dark)
    // Here we approximate
    Color bgColor = color.withOpacity(isDarkMode ? 0.2 : 0.1);
    if (label == 'Pass')
      bgColor = isDarkMode
          ? const Color(0xff064e3b).withOpacity(0.4)
          : const Color(0xffd1fae5);
    if (label == 'Fail')
      bgColor = isDarkMode
          ? const Color(0xff881337).withOpacity(0.4)
          : const Color(0xffffe4e6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.25),
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
    );
  }
}
