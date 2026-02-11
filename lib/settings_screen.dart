import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'widgets/profile_image.dart';

class SettingsScreen extends StatelessWidget {
  final String uid;
  const SettingsScreen({super.key, required this.uid});

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService().logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDarkMode
        ? const Color(0xff101722)
        : const Color(0xfff6f7f8);
    final Color surfaceColor = isDarkMode
        ? const Color(0xff1e293b)
        : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xff1e293b);
    final Color subTextColor = isDarkMode
        ? const Color(0xff94a3b8)
        : const Color(0xff64748b);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            StreamBuilder(
              stream: DatabaseService().users.doc(uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data == null) return const SizedBox();

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(userData: data),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ProfileImage(
                          imageUrl: data['imageUrl'] ?? '',
                          size: 64,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['fullName'] ?? 'User',
                                style: GoogleFonts.lexend(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Edit Profile',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: const Color(0xff0f68e6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: subTextColor),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // General Section
            _buildSectionHeader('General', subTextColor),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: ThemeService().themeMode,
                    builder: (context, themeMode, _) {
                      final isDark =
                          themeMode == ThemeMode.dark ||
                          (themeMode == ThemeMode.system &&
                              MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark);
                      return _buildSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        value: isDark,
                        onChanged: (val) => ThemeService().toggleTheme(),
                        textColor: textColor,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Account Section
            _buildSectionHeader('Account', subTextColor),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon')),
                      );
                    },
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon')),
                      );
                    },
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Support Section
            _buildSectionHeader('Support', subTextColor),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About RouteMinds',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'RouteMinds',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 RouteMinds Inc.',
                      );
                    },
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Logout
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _handleLogout(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xfffee2e2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Log Out',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffef4444),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
    required Color subTextColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: textColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: subTextColor,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: textColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: const Color(0xff0f68e6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
