import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isStudent = true;
  bool isPasswordVisible = false;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDarkMode ? backgroundDark : backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xff1e293b);
    final Color subTextColor = isDarkMode
        ? const Color(0xff94a3b8)
        : const Color(0xff64748b);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_stories_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'RouteMinds',
                      style: GoogleFonts.lexend(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Education Management System',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Role Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0x331e293b)
                      : const Color(0x1a64748b),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isStudent = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isStudent
                                ? (isDarkMode
                                      ? const Color(0xff334155)
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isStudent
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Student',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: isStudent
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isStudent ? primaryColor : subTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isStudent = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isStudent
                                ? (isDarkMode
                                      ? const Color(0xff334155)
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: !isStudent
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Teacher',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: !isStudent
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: !isStudent ? primaryColor : subTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Profile Selector Section
              if (isStudent) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SELECT STUDENT PROFILE',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subTextColor.withOpacity(0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Edit',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildProfileItem(
                        'Alex M.',
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDGFL5aURg5sqXStr9fZhJVvsl416mnmXIo6QTy_NfY7fN_zQzFv-nsPCsRA_x_hoZEwuiWdbry9Gm0YCqc6NykZXDARb1KFZd9CaC1M_2nyvht8pnY8qoI8qzh8kz3iAYrQor1MDEtocedlO__X_kchHrl3A2FaqQviGMvSCIJRoUjvnJefuJ_zuV7TXmSqhp3aRf_mGPAdStxlbCbA76OvcKCPVbrZZoGiObxYdc0AKI7Mg7FsQKWN-9V6hbYIGNHBsi9Xh7TF6s',
                        true,
                        isDarkMode,
                      ),
                      const SizedBox(width: 16),
                      _buildProfileItem(
                        'Sarah J.',
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAm4CDfLnL4Bq7ya-etPHwOvXxV8xSXk5aMIgO2ibs6fyn5eZJSC16_B0e54ZifNn1rHh86IkKHbNX3l-AFhxpCGM-8p-KSj2cjMv1ZsYwGDXpF4YCFo-ABLepIRDeI-EXpStKFrXB6-1ghBE5XfzLxK2GaGcRD_IxA1kbLzuiC3J76bXi64Kf4suINmFJ1R8CjWvv0svksi3O2HyPYf7I4MmPz8wtLeBrAeDRslxP03AWae4IefKKU0FY_rXzSV0pLfZotEGlX2ok',
                        false,
                        isDarkMode,
                      ),
                      const SizedBox(width: 16),
                      _buildAddProfileItem(isDarkMode),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Form Fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Student ID',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  _buildTextField(
                    controller: _idController,
                    hint: 'Enter your ID number',
                    icon: Icons.badge_outlined,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Password',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  _buildTextField(
                    controller: _passwordController,
                    hint: '••••••••',
                    icon: Icons.lock_open_outlined,
                    isPassword: true,
                    isPasswordVisible: isPasswordVisible,
                    onToggleVisibility: () =>
                        setState(() => isPasswordVisible = !isPasswordVisible),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => isStudent
                            ? const StudentDashboard()
                            : const TeacherDashboard(),
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return Colors.white10;
                            return null;
                          },
                        ),
                      ),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text.rich(
                TextSpan(
                  text: 'Need help? ',
                  style: GoogleFonts.lexend(fontSize: 14, color: subTextColor),
                  children: [
                    TextSpan(
                      text: 'Contact Administrator',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Offline Ready
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'OFFLINE READY',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: Text(
                  'Your records and progress are saved locally and will sync when online.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(fontSize: 10, color: subTextColor),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    String name,
    String imageUrl,
    bool isSelected,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Opacity(
            opacity: isSelected ? 1.0 : 0.6,
            child: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? (isDarkMode ? Colors.white : Colors.black)
                : (isDarkMode ? Colors.white70 : Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildAddProfileItem(bool isDarkMode) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDarkMode ? Colors.white24 : Colors.black12,
              width: 2,
              style: BorderStyle.solid,
            ),
            // We can't easily do dashed border in basic Flutter without a package,
            // but solid with low opacity is a good approximation for now.
          ),
          child: Icon(
            Icons.add,
            color: isDarkMode ? Colors.white54 : Colors.black38,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'New',
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white54 : Colors.black38,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    required bool isDarkMode,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      style: GoogleFonts.lexend(
        fontSize: 16,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lexend(
          color: isDarkMode ? Colors.white38 : Colors.black38,
        ),
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? Colors.white38 : Colors.black38,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDarkMode ? Colors.white38 : Colors.black38,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: isDarkMode ? const Color(0xff1e293b) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode
                ? const Color(0xff334155)
                : const Color(0xffe2e8f0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode
                ? const Color(0xff334155)
                : const Color(0xffe2e8f0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}
