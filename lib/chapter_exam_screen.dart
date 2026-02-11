import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'certificate_screen.dart';

class Question {
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });
}

class ChapterExamScreen extends StatefulWidget {
  final String chapterTitle;
  const ChapterExamScreen({super.key, this.chapterTitle = "Advanced Algebra"});

  @override
  State<ChapterExamScreen> createState() => _ChapterExamScreenState();
}

class _ChapterExamScreenState extends State<ChapterExamScreen>
    with WidgetsBindingObserver {
  final Color primaryColor = const Color(0xff0f68e6);
  final Color backgroundLight = const Color(0xfff6f7f8);
  final Color backgroundDark = const Color(0xff101722);

  late List<Question> _questions;
  int _currentIndex = 0;
  Map<int, int?> _answers = {};
  bool _isFinished = false;

  late Timer _timer;
  int _secondsLeft = 2700; // 45 minutes

  // Security checks
  bool _isSecurityCheckActive = true;
  bool _isSecurityViolation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _generateRandomQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isFinished && _isSecurityCheckActive) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        // App went to background or lost focus
        _handleSecurityViolation();
      }
    }
  }

  void _handleSecurityViolation() {
    // Prevent multiple triggers if already finished
    if (_isFinished) return;

    if (mounted) {
      // Close any open dialogs first
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exam terminated due to security violation.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );

      setState(() {
        _isSecurityViolation = true;
        _isFinished = true;
        _isSecurityCheckActive = false;
      });
    }
  }

  void _generateRandomQuestions() {
    final List<Question> allQuestions = [
      Question(
        text:
            "If a function f(x) is defined as 2x² - 3x + 5, what is the value of f(4)?",
        options: ["21", "25", "27", "32"],
        correctOptionIndex: 1,
      ),
      Question(
        text:
            "What is the result of solving for x in the equation 3x + 7 = 22?",
        options: ["3", "5", "7", "15"],
        correctOptionIndex: 1,
      ),
      Question(
        text:
            "Which of the following describes a parabola that opens downwards?",
        options: ["f(x) = x²", "f(x) = -x² + 4", "f(x) = |x|", "f(x) = 2x - 1"],
        correctOptionIndex: 1,
      ),
      Question(
        text: "Simplify: (x + 3)(x - 3)",
        options: ["x² + 6x + 9", "x² - 6x + 9", "x² - 9", "x² + 9"],
        correctOptionIndex: 2,
      ),
      Question(
        text:
            "What is the slope of the line passing through (1, 2) and (3, 6)?",
        options: ["1", "2", "3", "4"],
        correctOptionIndex: 1,
      ),
      Question(
        text: "Find the vertex of the parabola f(x) = (x - 2)² + 3.",
        options: ["(2, 3)", "(-2, 3)", "(2, -3)", "(3, 2)"],
        correctOptionIndex: 0,
      ),
      Question(
        text: "If x = 2 and y = 5, what is the value of 3x + 2y?",
        options: ["11", "13", "16", "21"],
        correctOptionIndex: 2,
      ),
      Question(
        text: "What is the square root of 144?",
        options: ["10", "11", "12", "14"],
        correctOptionIndex: 2,
      ),
      Question(
        text: "Factor the expression: x² - 5x + 6",
        options: ["(x-1)(x-6)", "(x-2)(x-3)", "(x+2)(x+3)", "(x-5)(x+1)"],
        correctOptionIndex: 1,
      ),
      Question(
        text: "What is the y-intercept of f(x) = 4x + 9?",
        options: ["4", "0", "9", "-9"],
        correctOptionIndex: 2,
      ),
      Question(
        text: "If log₂(x) = 3, what is x?",
        options: ["6", "8", "9", "5"],
        correctOptionIndex: 1,
      ),
      Question(
        text: "Solve: 2x / 4 = 10",
        options: ["10", "20", "40", "5"],
        correctOptionIndex: 1,
      ),
      Question(
        text: "What is the value of 5!",
        options: ["60", "120", "24", "10"],
        correctOptionIndex: 1,
      ),
      Question(
        text: "The sum of angles in a triangle is:",
        options: ["90°", "180°", "270°", "360°"],
        correctOptionIndex: 1,
      ),
      Question(
        text: "What is the base of natural logarithms?",
        options: ["10", "2", "e", "π"],
        correctOptionIndex: 2,
      ),
    ];

    allQuestions.shuffle();
    // Select between 10 and 15 questions randomly
    final int count = 10 + Random().nextInt(6);
    _questions = allQuestions.take(count).toList();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer.cancel();
        _finishExam();
      }
    });
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _finishExam() {
    if (_isFinished) return; // Prevent multiple calls
    _isSecurityCheckActive = false;
    setState(() {
      _isFinished = true;
    });
  }

  int _calculateScore() {
    int score = 0;
    _answers.forEach((index, answer) {
      if (answer == _questions[index].correctOptionIndex) {
        score++;
      }
    });
    return score;
  }

  Future<bool> _onWillPop() async {
    if (_isFinished) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Exam?'),
        content: const Text(
          'Are you sure you want to quit?\nYour progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isFinished) {
      return PopScope(canPop: true, child: _buildResultView(isDarkMode));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDarkMode),
              Expanded(child: _buildQuestionArea(isDarkMode)),
              _buildFooter(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    double progress = (_currentIndex + 1) / _questions.length;

    return Container(
      color: isDarkMode ? backgroundDark : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chapterTitle.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        "Question ${_currentIndex + 1}",
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "of ${_questions.length}",
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(_secondsLeft),
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.cloud_off, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "OFFLINE MODE ACTIVE",
                        style: GoogleFonts.lexend(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionArea(bool isDarkMode) {
    final question = _questions[_currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ...List.generate(question.options.length, (index) {
            bool isSelected = _answers[_currentIndex] == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildOption(
                index,
                question.options[index],
                isSelected,
                isDarkMode,
              ),
            );
          }),
          const SizedBox(height: 24),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  "Auto-saved locally at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} AM",
                  style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    int index,
    String text,
    bool isSelected,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _answers[_currentIndex] = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDarkMode ? 0.1 : 0.05)
              : (isDarkMode ? const Color(0xff1e293b) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : (isDarkMode
                            ? Colors.grey.shade600
                            : Colors.grey.shade300),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? (isDarkMode ? Colors.white : Colors.black87)
                      : (isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: isDarkMode ? backgroundDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: _currentIndex > 0
                  ? () {
                      setState(() {
                        _currentIndex--;
                      });
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(
                  color: isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade200,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Previous",
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentIndex < _questions.length - 1) {
                  setState(() {
                    _currentIndex++;
                  });
                } else {
                  _finishExam();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentIndex < _questions.length - 1
                        ? "Next Question"
                        : "Finish Exam",
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(bool isDarkMode) {
    int score = _isSecurityViolation ? 0 : _calculateScore();
    double percentage = (score / _questions.length) * 100;

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _isSecurityViolation
                      ? Colors.red.withValues(alpha: 0.1)
                      : primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _isSecurityViolation
                        ? Icons.gpp_bad_rounded
                        : (percentage >= 50
                              ? Icons.emoji_events
                              : Icons.sentiment_very_dissatisfied),
                    size: 60,
                    color: _isSecurityViolation ? Colors.red : primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _isSecurityViolation
                    ? "Exam Terminated"
                    : (percentage >= 50
                          ? "Exam Completed!"
                          : "Keep Practicing!"),
                style: GoogleFonts.lexend(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isSecurityViolation
                    ? "Security violation detected."
                    : "You scored $score out of ${_questions.length} questions",
                style: GoogleFonts.lexend(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              _buildResultCard(
                "Percentage",
                "${percentage.toInt()}%",
                Colors.orange,
                isDarkMode,
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                "Time Taken",
                _formatTime(2700 - _secondsLeft),
                Colors.blue,
                isDarkMode,
              ),
              const SizedBox(height: 16),
              _buildResultCard("Status", "FAILED", Colors.red, isDarkMode),
              const SizedBox(height: 64),
              if (percentage >= 50) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CertificateScreen(
                            userName:
                                "Sarah Jenkins", // In a real app, this would come from user profile
                            courseTitle: widget.chapterTitle,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(color: primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "View Certificate",
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Back to Chapter",
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String label,
    String value,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xff1e293b) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
