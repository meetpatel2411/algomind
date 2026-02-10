import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';

class AddEditClassScreen extends StatefulWidget {
  final String? classId;
  final Map<String, dynamic>? classData;

  const AddEditClassScreen({super.key, this.classId, this.classData});

  @override
  State<AddEditClassScreen> createState() => _AddEditClassScreenState();
}

class _AddEditClassScreenState extends State<AddEditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService();

  final Color primaryColor = const Color(0xff0f68e6);
  final Color successColor = const Color(0xff10b981);
  final Color dangerColor = const Color(0xffef4444);

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _subjectController;
  late TextEditingController _sectionController;
  late TextEditingController _roomController;
  late TextEditingController _studentCountController;

  // Selected values
  String _selectedDay = 'Monday';
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);

  bool _isSaving = false;
  bool get _isEditMode => widget.classId != null;

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.classData?['name'] ?? '',
    );
    _subjectController = TextEditingController(
      text: widget.classData?['subject'] ?? '',
    );
    _sectionController = TextEditingController(
      text: widget.classData?['section'] ?? '',
    );
    _roomController = TextEditingController(
      text: widget.classData?['room'] ?? '',
    );
    _studentCountController = TextEditingController(
      text: widget.classData?['studentCount']?.toString() ?? '0',
    );

    if (_isEditMode && widget.classData != null) {
      _selectedDay = widget.classData!['dayOfWeek'] ?? 'Monday';
      _parseTime(widget.classData!['startTime'], true);
      _parseTime(widget.classData!['endTime'], false);
    }
  }

  void _parseTime(String? timeStr, bool isStartTime) {
    if (timeStr == null) return;
    try {
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (parts.length > 1 && parts[1] == 'PM' && hour != 12) {
        hour += 12;
      } else if (parts.length > 1 && parts[1] == 'AM' && hour == 12) {
        hour = 0;
      }

      if (isStartTime) {
        _startTime = TimeOfDay(hour: hour, minute: minute);
      } else {
        _endTime = TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Keep default times if parsing fails
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _sectionController.dispose();
    _roomController.dispose();
    _studentCountController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate time
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (_isEditMode) {
        // Update existing class
        await _db.updateClass(widget.classId!, {
          'name': _nameController.text.trim(),
          'subject': _subjectController.text.trim(),
          'section': _sectionController.text.trim(),
          'room': _roomController.text.trim(),
          'startTime': _formatTimeOfDay(_startTime),
          'endTime': _formatTimeOfDay(_endTime),
          'dayOfWeek': _selectedDay,
          'studentCount': int.tryParse(_studentCountController.text) ?? 0,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class updated successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        // Create new class
        await _db.createClass(
          teacherId: teacherId,
          name: _nameController.text.trim(),
          subject: _subjectController.text.trim(),
          section: _sectionController.text.trim(),
          room: _roomController.text.trim(),
          startTime: _formatTimeOfDay(_startTime),
          endTime: _formatTimeOfDay(_endTime),
          dayOfWeek: _selectedDay,
          studentCount: int.tryParse(_studentCountController.text) ?? 0,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class created successfully')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteClass() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text(
          'Are you sure you want to delete this class? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.classId != null) {
      try {
        await _db.deleteClass(widget.classId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class deleted successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting class: $e')));
        }
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
    final Color subTextColor = isDarkMode
        ? const Color(0xff94a3b8)
        : const Color(0xff64748b);
    final Color borderColor = isDarkMode
        ? const Color(0xff334155)
        : const Color(0xffe2e8f0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Class' : 'Add New Class',
          style: GoogleFonts.lexend(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: dangerColor),
              onPressed: _deleteClass,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Class Name',
              hint: 'e.g., Class 12-A',
              icon: Icons.class_outlined,
              textColor: textColor,
              subTextColor: subTextColor,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _subjectController,
              label: 'Subject',
              hint: 'e.g., Mathematics',
              icon: Icons.book_outlined,
              textColor: textColor,
              subTextColor: subTextColor,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _sectionController,
                    label: 'Section',
                    hint: 'e.g., A',
                    icon: Icons.group_outlined,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _roomController,
                    label: 'Room',
                    hint: 'e.g., 204',
                    icon: Icons.meeting_room_outlined,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _studentCountController,
              label: 'Student Count',
              hint: '0',
              icon: Icons.people_outline_rounded,
              keyboardType: TextInputType.number,
              textColor: textColor,
              subTextColor: subTextColor,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Schedule',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildDaySelector(
              surfaceColor,
              borderColor,
              textColor,
              subTextColor,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: 'Start Time',
                    time: _startTime,
                    onTap: () => _selectTime(true),
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimePicker(
                    label: 'End Time',
                    time: _endTime,
                    onTap: () => _selectTime(false),
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Update Class' : 'Create Class',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color textColor,
    required Color subTextColor,
    required Color surfaceColor,
    required Color borderColor,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.lexend(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.lexend(color: subTextColor.withOpacity(0.5)),
            prefixIcon: Icon(icon, color: primaryColor),
            filled: true,
            fillColor: surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDaySelector(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day of Week',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedDay,
            style: GoogleFonts.lexend(color: textColor),
            dropdownColor: surfaceColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
            items: _daysOfWeek.map((day) {
              return DropdownMenuItem(value: day, child: Text(day));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedDay = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatTimeOfDay(time),
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
