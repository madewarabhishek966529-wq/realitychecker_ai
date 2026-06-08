import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/study_deck_model.dart';
import '../models/quiz_question_model.dart';

class QuizScreen extends StatefulWidget {
  final StudyDeck deck;

  const QuizScreen({super.key, required this.deck});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.deck.quizQuestions)..shuffle();
  }

  QuizQuestion get _current => _questions[_currentIndex];
  bool get _isDone => _currentIndex >= _questions.length;

  void _select(String answer) {
    if (_answered) return;
    final correct = answer == _current.answer;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (correct) _score++;
    });
  }

  void _next() {
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  Color _optionColor(String option) {
    if (!_answered) return const Color(0xFF1A1A2E);
    if (option == _current.answer) return const Color(0xFF064E3B);
    if (option == _selectedAnswer) return const Color(0xFF450A0A);
    return const Color(0xFF1A1A2E);
  }

  Color _optionBorderColor(String option) {
    if (!_answered) return Colors.white12;
    if (option == _current.answer) return const Color(0xFF34D399);
    if (option == _selectedAnswer) return Colors.redAccent;
    return Colors.white12;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: Text('Quiz',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _isDone
                    ? 'Done!'
                    : '${_currentIndex + 1}/${_questions.length}',
                style:
                    GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: _isDone ? _buildResultScreen() : _buildQuizBody(),
    );
  }

  Widget _buildQuizBody() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _currentIndex / _questions.length,
          backgroundColor: Colors.white10,
          valueColor: const AlwaysStoppedAnimation(Color(0xFF34D399)),
          minHeight: 3,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A5F), Color(0xFF1A1A2E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    _current.question,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ..._current.options.asMap().entries.map((e) {
                  final letter = ['A', 'B', 'C', 'D'][e.key];
                  final option = e.value;
                  final isCorrect =
                      _answered && option == _current.answer;
                  final isWrong = _answered &&
                      option == _selectedAnswer &&
                      option != _current.answer;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _select(option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _optionColor(option),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _optionBorderColor(option), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? const Color(0xFF34D399)
                                    : isWrong
                                        ? Colors.redAccent
                                        : Colors.white12,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isCorrect
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 18)
                                    : isWrong
                                        ? const Icon(Icons.close_rounded,
                                            color: Colors.white, size: 18)
                                        : Text(letter,
                                            style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                option,
                                style: GoogleFonts.outfit(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(key: ValueKey('$_currentIndex-${e.key}')).fadeIn(
                        delay: (e.key * 60).ms, duration: 250.ms),
                  );
                }),
                if (_answered && _current.explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _current.explanation,
                            style: GoogleFonts.outfit(
                                color: Colors.amber.shade200,
                                fontSize: 13,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_answered)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _currentIndex == _questions.length - 1
                      ? 'See Results'
                      : 'Next Question',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultScreen() {
    final pct = _questions.isEmpty ? 0 : (_score / _questions.length * 100).toInt();
    final color = pct >= 80
        ? const Color(0xFF34D399)
        : pct >= 50
            ? const Color(0xFFFBBF24)
            : Colors.redAccent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Quiz Complete!',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700))
                .animate()
                .fadeIn()
                .slideY(begin: -0.1),
            const SizedBox(height: 30),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 6),
                color: color.withOpacity(0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$pct%',
                      style: GoogleFonts.outfit(
                          color: color,
                          fontSize: 42,
                          fontWeight: FontWeight.w800)),
                  Text('Score',
                      style: GoogleFonts.outfit(
                          color: Colors.white54, fontSize: 14)),
                ],
              ),
            )
                .animate()
                .scale(duration: 700.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text('$_score / ${_questions.length} correct',
                style: GoogleFonts.outfit(
                    color: Colors.white70, fontSize: 17)),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.home_rounded, color: Colors.white),
                label: Text('Back to Deck',
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
