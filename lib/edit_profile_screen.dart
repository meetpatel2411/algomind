import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database_service.dart';
import 'widgets/profile_image.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String? uid;

  const EditProfileScreen({super.key, required this.userData, this.uid});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  bool _isLoading = false;
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['fullName']);
    _phoneController = TextEditingController(
      text: widget.userData['phoneNumber'],
    );
    _bioController = TextEditingController(text: widget.userData['bio']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final uid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await _db.updateUserProfile(uid, {
            'fullName': _nameController.text.trim(),
            'phoneNumber': _phoneController.text.trim(),
            'bio': _bioController.text.trim(),
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
            Navigator.pop(context, true); // Return true to indicate update
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
    final Color primaryColor = const Color(0xff0f68e6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
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
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    ProfileImage(
                      imageUrl: widget.userData['imageUrl'] ?? '',
                      size: 100,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: surfaceColor, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                textColor: textColor,
                surfaceColor: surfaceColor,
                isDarkMode: isDarkMode,
                validator: (val) => val!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                textColor: textColor,
                surfaceColor: surfaceColor,
                isDarkMode: isDarkMode,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bioController,
                label: 'Bio / About',
                icon: Icons.info_outline_rounded,
                textColor: textColor,
                surfaceColor: surfaceColor,
                isDarkMode: isDarkMode,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color textColor,
    required Color surfaceColor,
    required bool isDarkMode,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.lexend(color: textColor),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: isDarkMode ? Colors.white38 : const Color(0xff94a3b8),
            ),
            filled: true,
            fillColor: surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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
              borderSide: const BorderSide(color: Color(0xff0f68e6), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
