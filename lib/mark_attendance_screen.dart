import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'attendance_summary_screen.dart';
import 'services/database_service.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String subjectId;
  final String teacherId;
  final String classId;
  final String className;
  final String subjectName;
  final DateTime date;

  const MarkAttendanceScreen({
    super.key,
    required this.subjectId,
    required this.teacherId,
    required this.classId,
    required this.className,
    required this.subjectName,
    required this.date,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final DatabaseService _db = DatabaseService();
  final Color primaryColor = const Color(0xff0f68e6);
  final Color successColor = const Color(0xff10b981);
  final Color dangerColor = const Color(0xffef4444);
  final Color warningColor = const Color(0xfff59e0b);

  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  void _fetchStudents() {
    // In a real app, we would fetch students for widget.classId.
    // However, DatabaseService returns a Stream<QuerySnapshot>.
    // We should listen to it or use a StreamBuilder.
    // For simplicity in this stateful widget method (which was likely a copy-paste intended for a Future),
    // let's just listen to the stream once.

    _db.getStudentsByClass(widget.classId).listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _students = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name':
                data['fullName'] ??
                data['name'] ??
                data['displayName'] ??
                'Unknown Student',
            'rollNumber': data['rollNumber'] ?? data['studentId'] ?? 'N/A',
            'section': data['section'] ?? '', // Store section locally
            'status': 'Present',
            'remarks': '',
          };
        }).toList();
        _isLoading = false;
      });
    });
  }

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);

    try {
      final records = _students.map((s) {
        return {
          'studentId': s['id'],
          'studentName': s['name'],
          'className': widget.className,
          'section': s['section'] ?? '',
          'subjectName': widget.subjectName,
          'status': s['status'],
          'remarks': s['remarks'],
        };
      }).toList();

      await _db.markAttendance(
        widget.classId,
        widget.subjectId,
        widget.teacherId,
        widget.date,
        records,
      );

      if (mounted) {
        // Calculate stats for summary
        final totalFn = _students.length;
        final presentFn = _students
            .where((s) => s['status'] == 'Present')
            .length;
        final absentFn = totalFn - presentFn;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceSummaryScreen(
              className: widget.className,
              subject: widget.subjectName,
              date: DateFormat('h:mm a').format(DateTime.now()),
              presentCount: presentFn,
              absentCount: absentFn,
              totalCount: totalFn,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving attendance: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _toggleStatus(int index) {
    setState(() {
      final current = _students[index]['status'];
      if (current == 'Present') {
        _students[index]['status'] = 'Absent';
      } else {
        _students[index]['status'] = 'Present';
      }
    });
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.className,
              style: GoogleFonts.lexend(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              DateFormat('EEE, d MMMM').format(widget.date),
              style: GoogleFonts.lexend(
                color: subTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveAttendance,
              child: Text(
                'Save',
                style: GoogleFonts.lexend(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final student = _students[index];
                final status = student['status'];
                Color statusColor;
                IconData statusIcon;

                switch (status) {
                  case 'Absent':
                    statusColor = dangerColor;
                    statusIcon = Icons.cancel_rounded;
                    break;
                  default: // Present
                    statusColor = successColor;
                    statusIcon = Icons.check_circle_rounded;
                }

                return GestureDetector(
                  onTap: () => _toggleStatus(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            student['name'].substring(0, 1).toUpperCase(),
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student['name'],
                                style: GoogleFonts.lexend(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Roll No: ${student['rollNumber']}',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                status.toUpperCase(),
                                style: GoogleFonts.lexend(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
