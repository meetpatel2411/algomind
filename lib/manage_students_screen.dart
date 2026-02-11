import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';
import 'widgets/profile_image.dart';
import 'student_profile_screen.dart';
import 'widgets/teacher_bottom_navigation.dart';
// Duplicate imports removed

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

  // int _selectedIndex = 1; // Removed unused variable
  String? _selectedClassId;
  String _searchQuery = ''; // New state for search

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
                        const SizedBox(height: 16),
                        _buildClassFilter(
                          surfaceColor,
                          textColor,
                          subTextColor,
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _selectedClassId == null
                                ? DatabaseService().getStudents()
                                : DatabaseService().getStudentsByClass(
                                    _selectedClassId!,
                                  ),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final allStudents = snapshot.data?.docs ?? [];

                              // Client-side filtering for search & class
                              final students = allStudents.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final fullName = (data['fullName'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                final className =
                                    (data['className'] ?? data['classId'] ?? '')
                                        .toString()
                                        .toLowerCase();
                                final section = (data['section'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                final query = _searchQuery.toLowerCase();

                                return fullName.contains(query) ||
                                    className.contains(query) ||
                                    section.contains(query);
                              }).toList();

                              if (students.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No students found.',
                                    style: GoogleFonts.lexend(
                                      color: subTextColor,
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: students.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final data =
                                      students[index].data()
                                          as Map<String, dynamic>;
                                  return _buildStudentCard(
                                    data['fullName'] ?? 'Student Name',
                                    'Class ${data['className'] ?? data['classId'] ?? '-'} • Section ${data['section']?.toString().toUpperCase() ?? '-'}',
                                    data['imageUrl'] ??
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCbLqF1z_brevwevj8gLnDNbnF8bSW65w67IYIGtfVOU5EC0EKTxTMx0O1iIaQMNyA-bxBSvfRocMdwKcWzz2vPTaRDFtzQXkDiLN34i-qqeKeb0gBv2zU8YBZmFhxrWOTLwBdmWi4Qy7v8AIztiRYbLh9zSjVklru0GkP6jplzU3KQ0ufowmEjhD4tFz4GA8YH7hpdtpJszEamC6h_9-7tO9cS-XPIG6tuapKyaMZSnDruaZywL1FTlsy19krzH-i7pSQexpak_po',
                                    surfaceColor,
                                    borderColor,
                                    textColor,
                                    subTextColor,
                                    isDarkMode,
                                    onEdit: () => _showStudentDialog(
                                      student: data,
                                      uid: students[index].id,
                                    ),
                                    onDelete: () =>
                                        _confirmDelete(students[index].id),
                                  );
                                },
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
                onPressed: () => _showStudentDialog(),
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

  // --- CRUD LOGIC ---

  Future<void> _showStudentDialog({
    Map<String, dynamic>? student,
    String? uid,
  }) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: student?['fullName'] ?? '',
    );
    final emailController = TextEditingController(
      text: student?['email'] ?? '',
    );
    final classController = TextEditingController(
      text: student?['classId'] ?? '',
    );
    final sectionController = TextEditingController(
      text: student?['section'] ?? '',
    );

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => AlertDialog(
        title: Text(
          student == null ? 'Add Student' : 'Edit Student',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: classController,
                  decoration: const InputDecoration(
                    labelText: 'Class (Numeric only)',
                    hintText: 'e.g. 10',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Class is required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Class must be a number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: sectionController,
                  decoration: const InputDecoration(
                    labelText: 'Section',
                    hintText: 'e.g. A',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Section is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final data = {
                  'fullName': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'classId': classController.text.trim(),
                  'section': sectionController.text.trim(),
                };

                try {
                  if (student == null) {
                    await DatabaseService().addStudent(data);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Student Added')),
                      );
                    }
                  } else {
                    await DatabaseService().updateStudent(uid!, data);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Student Updated')),
                      );
                    }
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: Text(student == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseService().deleteStudent(uid);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Student Deleted')));
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildHeader(bool isDarkMode, Color subTextColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text(
        'Manage Students',
        style: GoogleFonts.lexend(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          style: GoogleFonts.lexend(fontSize: 14),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by name, class or section...',
            hintStyle: GoogleFonts.lexend(
              color: subTextColor.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: subTextColor.withValues(alpha: 0.6),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildClassFilter(
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
  ) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseService().getTeacherClasses(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final classes = snapshot.data!.docs;
        // If no classes, don't show filter (or show empty state handled elsewhere)
        if (classes.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: textColor.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedClassId,
                hint: Text(
                  'Filter by Class',
                  style: GoogleFonts.lexend(color: subTextColor),
                ),
                isExpanded: true,
                icon: Icon(Icons.filter_list_rounded, color: primaryColor),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'All Students',
                      style: GoogleFonts.lexend(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ...classes.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: doc.id, // Using QueryDocumentSnapshot id
                      child: Text(
                        '${data['name']} (${data['section'] ?? ''})',
                        style: GoogleFonts.lexend(color: textColor),
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedClassId = value;
                  });
                },
                dropdownColor: surfaceColor,
              ),
            ),
          ),
        );
      },
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
    bool isDarkMode, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
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
              color: Colors.black.withValues(alpha: 0.02),
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
              borderColor: primaryColor.withValues(alpha: 0.2),
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
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  color: subTextColor.withValues(alpha: 0.6),
                  splashRadius: 20,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: Colors.redAccent.withValues(alpha: 0.6),
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
    return TeacherBottomNavigation(currentIndex: 1, isDarkMode: isDarkMode);
  }
}
