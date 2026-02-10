import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';
import 'widgets/teacher_bottom_navigation.dart';
import 'create_exam_screen.dart';
import 'widgets/profile_image.dart';
import 'exam_details_screen.dart';

class ManageExamsScreen extends StatefulWidget {
  const ManageExamsScreen({super.key});

  @override
  State<ManageExamsScreen> createState() => _ManageExamsScreenState();
}

class _ManageExamsScreenState extends State<ManageExamsScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);

  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'All Exams',
    'Upcoming',
    'Ongoing',
    'Completed',
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
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(isDarkMode, textColor, subTextColor),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildFilterPills(subTextColor),
                        const SizedBox(height: 24),
                        StreamBuilder<QuerySnapshot>(
                          stream: DatabaseService().getExams(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                              return Text('Error: ${snapshot.error}');
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final exams = snapshot.data?.docs ?? [];

                            if (exams.isEmpty) {
                              return Center(
                                child: Text(
                                  'No exams found.',
                                  style: GoogleFonts.lexend(
                                    color: subTextColor,
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: exams.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final data =
                                    exams[index].data() as Map<String, dynamic>;
                                return _buildExamCard(
                                  data,
                                  surfaceColor,
                                  borderColor,
                                  textColor,
                                  subTextColor,
                                  isDarkMode,
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 100,
              right: 24,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateExamScreen(),
                    ),
                  );
                },
                backgroundColor: primaryColor,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
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

  Widget _buildHeader(bool isDarkMode, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? backgroundDark.withOpacity(0.8)
            : backgroundLight.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.white10 : const Color(0xffe2e8f0),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exams',
                style: GoogleFonts.lexend(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ProfileImage(
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuB8RoccHkfm2u4VVnSS5eo8dQPDBqPv87nYeYRyxh69SLXZM734PIJYe6mYavQupcXOWTB0xN7mpkzyURhE8eFHf0LwTn59iXth6tcA5EC73nfxTuJWOQozZaQuDRCnT4evJMiIWCFQN0IxTPBzpn3IfFmHvMWjfHuSGfBBgxqs9mJ522s2udLsfth2wrIdisWAajjV0Xt9INcbiyhP4C8jTA_ovabeQJ_STvIyy68IQpGG1JQRkEiHK04kF5B3B4hxDf7QwuMfBjc',
                    borderColor: primaryColor.withOpacity(0.2),
                    borderWidth: 2,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              style: GoogleFonts.lexend(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search exams or classes...',
                hintStyle: GoogleFonts.lexend(
                  color: subTextColor.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: subTextColor.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPills(Color subTextColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          bool isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedFilterIndex = index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xffe2e8f0)),
                ),
                child: Text(
                  _filters[index],
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : subTextColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildExamCard(
    Map<String, dynamic> exam,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    Color statusColor;
    Color statusBgColor;

    switch (exam['status']) {
      case 'Ongoing':
        statusColor = const Color(0xff10b981);
        statusBgColor = const Color(0xff10b981).withOpacity(0.1);
        break;
      case 'Upcoming':
        statusColor = primaryColor;
        statusBgColor = primaryColor.withOpacity(0.1);
        break;
      default:
        statusColor = subTextColor;
        statusBgColor = isDarkMode ? Colors.white10 : const Color(0xfff1f5f9);
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        exam['status'].toUpperCase(),
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_done_outlined,
                          size: 14,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Offline Saved',
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  exam['title'],
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.school_outlined, size: 16, color: subTextColor),
                    const SizedBox(width: 6),
                    Text(
                      exam['class'],
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: borderColor),
                      bottom: BorderSide(color: borderColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: subTextColor.withOpacity(0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              exam['date'],
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: subTextColor.withOpacity(0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              exam['duration'],
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: isDarkMode
                ? Colors.white.withOpacity(0.02)
                : const Color(0xfff8fafc),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCardAction(
                  Icons.visibility_outlined,
                  'View',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamDetailsScreen(examData: exam),
                      ),
                    );
                  },
                ),
                Container(width: 1, height: 16, color: borderColor),
                _buildCardAction(Icons.edit_outlined, 'Edit'),
                Container(width: 1, height: 16, color: borderColor),
                _buildCardAction(
                  Icons.analytics_outlined,
                  'Results',
                  enabled: exam['status'] != 'Upcoming',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAction(
    IconData icon,
    String label, {
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Row(
        children: [
          Icon(icon, size: 18, color: enabled ? primaryColor : Colors.grey),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: enabled ? primaryColor : Colors.grey,
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
    return TeacherBottomNavigation(currentIndex: 4, isDarkMode: isDarkMode);
  }
}
