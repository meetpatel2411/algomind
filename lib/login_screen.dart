import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_dashboard.dart';
import 'teacher_dashboard.dart';
import 'services/database_service.dart';
import 'services/seed_service.dart';
import 'services/auth_service.dart';
import 'widgets/profile_image.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isStudent = true;
  bool isPasswordVisible = false;
  bool _isLoading = false;
  final TextEditingController _emailController =
      TextEditingController(); // Changed from ID to Email
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService(); // Added
  List<ScheduledUser> _cachedUsers = []; // Added

  @override
  void initState() {
    super.initState();
    _loadCachedUsers();
  }

  Future<void> _loadCachedUsers() async {
    final users = await _authService.getStoredUsers();
    setState(() => _cachedUsers = users);
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      // TODO: In a real app, you might map ID to Email or just use Email
      // For now, assuming input is Email
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email and password')),
        );
        return;
      }

      // Online Login attempt
      try {
        UserCredential userCredential = await _authService.loginOnline(
          email,
          password,
          isStudent ? 'student' : 'teacher',
          'User',
        );
        // In real app, name is fetched after login, but for cache update we need it.
        // Ideally _authService fetches Firestore profile to cache name properly.

        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;

          // Re-fetch profile to ensure role correctness
          Map<String, dynamic>? userData = await _dbService.getUserProfile(uid);
          String role =
              userData?['role'] ?? (isStudent ? 'student' : 'teacher');
          String fullName = userData?['fullName'] ?? 'User';

          // Update Cache with correct details
          await _authService.cacheUser(userCredential.user!, role, fullName);
          await _loadCachedUsers(); // Refresh UI

          if (mounted) _navigateToDashboard(role, uid);
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Online Login Failed: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToDashboard(String role, String uid) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => role == 'student'
            ? const StudentDashboard()
            : TeacherDashboard(uid: uid),
      ),
    );
  }

  Future<void> _handleOfflineLogin(ScheduledUser user) async {
    // Show PIN Dialog
    final pinController = TextEditingController();
    bool? success = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Offline Access: ${user.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter 4-digit PIN (Default: 1234)'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text == '1234') {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );

    if (success == true) {
      _navigateToDashboard(user.role, user.uid);
    }
  }

  Future<void> _seedData() async {
    setState(() => _isLoading = true);
    try {
      await SeedService().seedDatabase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database Seeded Successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error seeding database: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? backgroundDark
          : backgroundLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Side - Branding
        Expanded(
          flex: 1,
          child: Container(
            color: primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'RouteMinds',
                  style: GoogleFonts.lexend(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Empowering Education,\nOffline & Everywhere.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right Side - Login Form
        Expanded(
          flex: 1,
          child: Center(
            child: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: _buildLoginForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Mobile Logo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome Back',
              style: GoogleFonts.lexend(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xff1e293b),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to your account',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : const Color(0xff64748b),
              ),
            ),
            const SizedBox(height: 48),
            _buildLoginForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xff1e293b);
    final Color subTextColor = isDarkMode
        ? const Color(0xff94a3b8)
        : const Color(0xff64748b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- OFFLINE / SAVED ACCOUNTS SECTION ---
        if (_cachedUsers.isNotEmpty) ...[
          Text(
            'SAVED ACCOUNTS (OFFLINE)',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: subTextColor,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _cachedUsers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final user = _cachedUsers[index];
                return GestureDetector(
                  onTap: () => _handleOfflineLogin(user),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 2),
                        ),
                        child: ProfileImage(
                          imageUrl: user.photoUrl ?? '',
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.fullName.split(' ')[0], // First name
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
        ],

        // Role Toggle
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xff1e293b)
                : const Color(0xfff1f5f9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: _buildRoleButton('Student', isStudent)),
              Expanded(child: _buildRoleButton('Teacher', !isStudent)),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Profile Selection (for Student)

        // Input Fields
        _buildInputField(
          label: 'Email Address',
          controller: _emailController,
          hint: 'name@example.com',
          icon: Icons.alternate_email_rounded,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'Password',
          controller: _passwordController,
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          isPasswordVisible: isPasswordVisible,
          onToggleVisibility: () =>
              setState(() => isPasswordVisible = !isPasswordVisible),
          isDarkMode: isDarkMode,
        ),

        const SizedBox(height: 24),
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
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: primaryColor.withOpacity(0.4),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Sign In',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 32),

        // Offline Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'OFFLINE READY',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xff10b981),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Developer Tools (Subtle)
        ExpansionTile(
          title: Text(
            'Developer Options',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: subTextColor.withOpacity(0.5),
            ),
          ),
          collapsedIconColor: subTextColor.withOpacity(0.5),
          iconColor: subTextColor,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: [
                TextButton.icon(
                  onPressed: _isLoading ? null : _seedData,
                  icon: const Icon(Icons.dataset_linked_outlined, size: 16),
                  label: const Text('Seed Data'),
                  style: TextButton.styleFrom(foregroundColor: subTextColor),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const TeacherDashboard(uid: 'teacher_123'),
                    ),
                  ),
                  icon: const Icon(Icons.school_outlined, size: 16),
                  label: const Text('Demo Teacher'),
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentDashboard(),
                    ),
                  ),
                  icon: const Icon(Icons.person_outline, size: 16),
                  label: const Text('Demo Student'),
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => isStudent = (label == 'Student')),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xff334155)
                    : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? primaryColor
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white54
                      : const Color(0xff64748b)),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white70 : const Color(0xff334155),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          style: GoogleFonts.lexend(
            color: isDarkMode ? Colors.white : const Color(0xff1e293b),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.lexend(
              color: isDarkMode ? Colors.white24 : Colors.black26,
            ),
            prefixIcon: Icon(
              icon,
              color: isDarkMode ? Colors.white38 : const Color(0xff94a3b8),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: isDarkMode
                          ? Colors.white38
                          : const Color(0xff94a3b8),
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: isDarkMode
                ? const Color(0xff0f172a)
                : const Color(0xfff8fafc),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode
                    ? const Color(0xff1e293b)
                    : const Color(0xffe2e8f0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
      ],
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
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Opacity(
            opacity: isSelected ? 1.0 : 0.6,
            child: ProfileImage(imageUrl: imageUrl, size: 48),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? (isDarkMode ? Colors.white : const Color(0xff1e293b))
                : (isDarkMode ? Colors.white54 : const Color(0xff64748b)),
          ),
        ),
      ],
    );
  }
}
