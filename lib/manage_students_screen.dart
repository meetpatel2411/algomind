import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'teacher_dashboard.dart';
import 'student_profile_screen.dart';
import 'widgets/profile_image.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);

  int _selectedIndex = 1;

  final List<Map<String, String>> _students = [
    {
      'name': 'Alexander Wright',
      'details': 'Grade 12 • Science A',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCbLqF1z_brevwevj8gLnDNbnF8bSW65w67IYIGtfVOU5EC0EKTxTMx0O1iIaQMNyA-bxBSvfRocMdwKcWzz2vPTaRDFtzQXkDiLN34i-qqeKeb0gBv2zU8YBZmFhxrWOTLwBdmWi4Qy7v8AIztiRYbLh9zSjVklru0GkP6jplzU3KQ0ufowmEjhD4tFz4GA8YH7hpdtpJszEamC6h_9-7tO9cS-XPIG6tuapKyaMZSnDruaZywL1FTlsy19krzH-i7pSQexpak_po',
    },
    {
      'name': 'Eleanor Martinez',
      'details': 'Grade 11 • Mathematics',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCM27HNiRxENobNZkXyJxoY4KF2atbCpHIoOp4cVxjeF_4jj2bTjIw9skm1rj16RmaILv0x5CS9OPA3u2l368mjQpwf3KXZDTxQk92ITKrxPWq80ClyNwrDgLuYRcT4lMYH_fHek9Fn5IYkkjQiuNuds0lxaZx16TrS2UVWvfC7r9b2qwgRP5p1YwTC2ySfgdyc2zzEqnTUmu--UJ0FaXU7DY3v0wclLE0-bjz-zCuHAMoNzzDsQMpNZN2Fz7Ht-L8TIElTamEHNdU',
    },
    {
      'name': 'Julian Henderson',
      'details': 'Grade 12 • Science B',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB6SPqHr3bk8D0YVsiSJuhrwIiY1wDl8ermEQJ7Fzk0nuZuS6JBPjVA0tAjk7Outtgmvi-WDhx-rQAL-A5HmuKnhk-z-BNdOeIWMo22-gRQORx9w0q4sQm6El8HZs3fdXsPQkqej1XjjRAfxQ9k4tH8xhDhCEOWRybw0MVSLN0vZouDTa1Za1I8wSMHE_lA8gcB1vOD8-er2adIpY0Q_nFUlIh2xQ_IaihyguNpeHuwNpgkD_Q9iH4PDnghFWWcLQufbTYm9C44oJg',
    },
    {
      'name': 'Maya Thompson',
      'details': 'Grade 10 • Literature',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA5kWxQBmaobyRBVwlPsNsuNv-K24TQbMJ-zrkitxFTlCPhTb1pF_odE3niFakFvWGvU8wCL_9zm1lDFXd5KczpCGR4kQFw8xdsHCTDLNlIRfCopAT4bB58UPjvQaUAce1MWZZCXW15N6-u7rvbGKZt3UtA2UvVpQkRzArKBtu0LixOWRmUjG2PqakmbZpMEhrOhFKlAyVfKwnzYimqcOjvATCAEMnok63NpmFPfE8fYaWJCXdRtKc7LrmhzPOpH4hbib3NWM0QDvA',
    },
    {
      'name': 'Owen Brooks',
      'details': 'Grade 11 • History',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAIPiUNBqKRZ11QvPDr2d8JTTmrW5xZY_uYbuYHIiUWebYq14iJa_oWz29AZQiBB6UQRo9mywFZvV-OiDd-8YeLMWm7l0muEbEVGj_Ai96MOOC_Dg64i-x6QqGtYk9msrVDmfyQ9hlSidwTOYPDejh4Swt1LWZzXFc4TJO9AHV79XYJi7awJbtYWtrpxkRCRlDSSxlspWdrRbJNLDcchJLRvm0cKI1RfChNvWkl9L5kAiBdVRbfUtonU9_qVvhgEJgMMeZ32DZikqc',
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
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(isDarkMode, subTextColor, textColor),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      children: [
                        _buildSearchBar(surfaceColor, subTextColor, isDarkMode),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _students.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final student = _students[index];
                              return _buildStudentCard(
                                student['name']!,
                                student['details']!,
                                student['image']!,
                                surfaceColor,
                                borderColor,
                                textColor,
                                subTextColor,
                                isDarkMode,
                              );
                            },
                          ),
                        ),
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
                onPressed: () {},
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

  Widget _buildHeader(bool isDarkMode, Color subTextColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    'Synced Offline',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
              Text(
                '10:45 AM',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Manage Students',
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    Color surfaceColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          style: GoogleFonts.lexend(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search by name or grade...',
            hintStyle: GoogleFonts.lexend(color: subTextColor.withOpacity(0.6)),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: subTextColor.withOpacity(0.6),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(
    String name,
    String details,
    String imageUrl,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentProfileScreen(
              studentData: {
                'name': name,
                'details': details,
                'image': imageUrl,
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            ProfileImage(
              imageUrl: imageUrl,
              size: 48,
              borderColor: primaryColor.withOpacity(0.2),
              borderWidth: 1,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    details,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  color: subTextColor.withOpacity(0.6),
                  splashRadius: 20,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: Colors.redAccent.withOpacity(0.6),
                  splashRadius: 20,
                ),
              ],
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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
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
          _buildNavItem(Icons.school_rounded, 'Students', 1, subTextColor),
          _buildNavItem(
            Icons.assignment_turned_in_rounded,
            'Attendance',
            2,
            subTextColor,
          ),
          _buildNavItem(Icons.history_edu_rounded, 'Exams', 3, subTextColor),
          _buildNavItem(Icons.menu_book_rounded, 'Courses', 4, subTextColor),
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
            MaterialPageRoute(builder: (context) => const TeacherDashboard()),
          );
        }
      },
      child: Column(
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
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? primaryColor : subTextColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
