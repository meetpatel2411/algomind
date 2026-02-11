import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/database_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);
  final Color successColor = const Color(0xff10b981);

  bool _isOfflineAvailable = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _marksController = TextEditingController();

  // Selections
  String? _selectedClassId;
  String? _selectedClassName;
  String? _selectedSubjectId;
  String? _selectedSubjectName;
  DateTime _selectedDate = DateTime.now();

  bool _isCreating = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'type': 'MCQ',
      'question': '',
      'options': ['', ''],
    },
    {'type': 'Open Text', 'question': ''},
  ];

  Future<void> _createExam() async {
    setState(() => _isCreating = true);
    try {
      if (_titleController.text.isEmpty ||
          _selectedClassId == null ||
          _selectedSubjectId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }

      final examData = {
        'title': _titleController.text.trim(),
        'classId': _selectedClassId,
        'className': _selectedClassName,
        'subjectId': _selectedSubjectId,
        'subjectName': _selectedSubjectName,
        'duration': '${_durationController.text.trim()} Mins',
        'totalMarks': int.tryParse(_marksController.text.trim()) ?? 100,
        'status': 'Upcoming',
        'isOffline': _isOfflineAvailable,
        'date': Timestamp.fromDate(_selectedDate),
        'teacherId': FirebaseAuth.instance.currentUser?.uid,
      };

      await DatabaseService().createExam(examData, _questions);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating exam: $e')));
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetadataSection(
                          surfaceColor,
                          borderColor,
                          textColor,
                          subTextColor,
                        ),
                        const SizedBox(height: 16),
                        Divider(color: borderColor),
                        const SizedBox(height: 16),
                        _buildQuestionBuilderHeader(textColor),
                        const SizedBox(height: 16),
                        _buildQuestionList(
                          surfaceColor,
                          borderColor,
                          textColor,
                          subTextColor,
                          isDarkMode,
                        ),
                        const SizedBox(height: 16),
                        _buildAddQuestionButton(subTextColor, borderColor),
                        const SizedBox(height: 24),
                        _buildOfflineSettings(
                          surfaceColor,
                          borderColor,
                          textColor,
                          subTextColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildStickyActionArea(surfaceColor, borderColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? backgroundDark.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.white10 : const Color(0xffe2e8f0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: subTextColor,
                  size: 20,
                ),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                splashRadius: 20,
              ),
              Text(
                'Create New Exam',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.cloud_done_rounded, color: successColor, size: 16),
              const SizedBox(width: 4),
              Text(
                'Synced',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: DatabaseService().getTeacherClasses(uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildDropdownField(
                      'Class',
                      [],
                      surfaceColor,
                      borderColor,
                      subTextColor,
                      null,
                      null,
                    );
                  }

                  final classes = snapshot.data!.docs;
                  final List<DropdownMenuItem<String>> items = classes.map((
                    doc,
                  ) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(data['name'] ?? 'Class'),
                      onTap: () {
                        setState(() => _selectedClassName = data['name']);
                      },
                    );
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'Class',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subTextColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedClassId,
                            hint: Text(
                              'Select Class',
                              style: GoogleFonts.lexend(color: subTextColor),
                            ),
                            icon: Icon(
                              Icons.expand_more_rounded,
                              color: subTextColor.withValues(alpha: 0.5),
                            ),
                            isExpanded: true,
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: subTextColor,
                            ),
                            onChanged: (val) {
                              setState(() {
                                _selectedClassId = val;
                                _selectedSubjectId = null; // Reset subject
                              });
                            },
                            items: items,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: DatabaseService().getSubjects(_selectedClassId),
                builder: (context, snapshot) {
                  List<DropdownMenuItem<String>> items = [];
                  if (snapshot.hasData) {
                    items = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(data['name'] ?? 'Subject'),
                        onTap: () {
                          setState(() => _selectedSubjectName = data['name']);
                        },
                      );
                    }).toList();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'Subject',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: subTextColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSubjectId,
                            hint: Text(
                              'Select Subject',
                              style: GoogleFonts.lexend(color: subTextColor),
                            ),
                            icon: Icon(
                              Icons.expand_more_rounded,
                              color: subTextColor.withValues(alpha: 0.5),
                            ),
                            isExpanded: true,
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: subTextColor,
                            ),
                            onChanged: _selectedClassId == null
                                ? null
                                : (val) {
                                    setState(() => _selectedSubjectId = val);
                                  },
                            items: items,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Exam Title',
          'e.g. Mid-term Assessment',
          surfaceColor,
          borderColor,
          subTextColor,
          controller: _titleController,
        ),
        const SizedBox(height: 16),
        // Date Picker
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDate: _selectedDate,
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'Exam Date',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: GoogleFonts.lexend(fontSize: 14, color: textColor),
                    ),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: subTextColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Duration (Min)',
                '60',
                surfaceColor,
                borderColor,
                subTextColor,
                keyboardType: TextInputType.number,
                controller: _durationController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                'Total Marks',
                '100',
                surfaceColor,
                borderColor,
                subTextColor,
                keyboardType: TextInputType.number,
                controller: _marksController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> options,
    Color surfaceColor,
    Color borderColor,
    Color subTextColor,
    ValueChanged<String?>? onChanged,
    String? value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value ?? options[0],
              icon: Icon(
                Icons.expand_more_rounded,
                color: subTextColor.withValues(alpha: 0.5),
              ),
              isExpanded: true,
              style: GoogleFonts.lexend(fontSize: 14, color: subTextColor),
              onChanged: onChanged,
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    Color surfaceColor,
    Color borderColor,
    Color subTextColor, {
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.lexend(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.lexend(
                color: subTextColor.withValues(alpha: 0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionBuilderHeader(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Question Builder',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_questions.length} Questions Added',
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionList(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        return _buildQuestionCard(
          index + 1,
          question,
          surfaceColor,
          borderColor,
          textColor,
          subTextColor,
          isDarkMode,
        );
      },
    );
  }

  Widget _buildQuestionCard(
    int number,
    Map<String, dynamic> question,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    final bool isMCQ = question['type'] == 'MCQ';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $number',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => _questions.removeAt(number - 1)),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: subTextColor.withValues(alpha: 0.5),
                ),
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? backgroundDark : backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              maxLines: 2,
              style: GoogleFonts.lexend(fontSize: 14),
              decoration: InputDecoration(
                hintText: isMCQ
                    ? 'Enter your question here...'
                    : 'Explain the theory of...',
                hintStyle: GoogleFonts.lexend(
                  color: subTextColor.withValues(alpha: 0.4),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  'Multiple Choice',
                  isMCQ,
                  () => setState(() => question['type'] = 'MCQ'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTypeButton(
                  'Open Text',
                  !isMCQ,
                  () => setState(() => question['type'] = 'Open Text'),
                ),
              ),
            ],
          ),
          if (isMCQ) ...[
            const SizedBox(height: 12),
            _buildMCQOption(
              'A',
              'Option A',
              true,
              borderColor,
              textColor,
              subTextColor,
            ),
            const SizedBox(height: 8),
            _buildMCQOption(
              'B',
              'Option B',
              false,
              borderColor,
              textColor,
              subTextColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xfff1f5f9)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xff64748b),
          ),
        ),
      ),
    );
  }

  Widget _buildMCQOption(
    String index,
    String hint,
    bool isSelected,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? primaryColor : borderColor,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            index,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? primaryColor : subTextColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: TextField(
              style: GoogleFonts.lexend(fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.lexend(
                  color: subTextColor.withValues(alpha: 0.4),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddQuestionButton(Color subTextColor, Color borderColor) {
    return InkWell(
      onTap: () => setState(
        () => _questions.add({
          'type': 'MCQ',
          'question': '',
          'options': ['', ''],
        }),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: 2,
            style: BorderStyle.solid,
          ), // Dash effect is hard in standard decorative container, solid border for now
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: subTextColor.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add New Question',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: subTextColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineSettings(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make Available Offline',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Students can take this exam without internet.',
                  style: GoogleFonts.lexend(fontSize: 10, color: subTextColor),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOfflineAvailable,
            onChanged: (val) => setState(() => _isOfflineAvailable = val),
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStickyActionArea(Color surfaceColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Material(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _isCreating ? null : _createExam,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isCreating)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  _isCreating ? 'Creating...' : 'Create Exam',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
