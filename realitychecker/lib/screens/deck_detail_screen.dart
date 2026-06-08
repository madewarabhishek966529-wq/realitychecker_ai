import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/study_deck_model.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';

class DeckDetailScreen extends StatelessWidget {
  final StudyDeck deck;

  const DeckDetailScreen({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    final progress = deck.totalCards == 0
        ? 0.0
        : (deck.totalCards - deck.dueToday) / deck.totalCards;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: Text(
          deck.title,
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Progress card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progress',
                              style: GoogleFonts.outfit(
                                  color: Colors.white54, fontSize: 13)),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF818CF8),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearPercentIndicator(
                        percent: progress.clamp(0.0, 1.0),
                        lineHeight: 8,
                        backgroundColor: Colors.white12,
                        progressColor: const Color(0xFF818CF8),
                        barRadius: const Radius.circular(8),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _InfoBadge(
                            label: '${deck.totalCards}',
                            sub: 'Total',
                            color: const Color(0xFF818CF8),
                          ),
                          const SizedBox(width: 12),
                          _InfoBadge(
                            label: '${deck.dueToday}',
                            sub: 'Due',
                            color: const Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 12),
                          _InfoBadge(
                            label:
                                '${(deck.overallAccuracy * 100).toInt()}%',
                            sub: 'Accuracy',
                            color: const Color(0xFF34D399),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.style_rounded,
                        label: 'Flashcards',
                        color: const Color(0xFF818CF8),
                        onTap: deck.flashcards.isEmpty
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          FlashCardScreen(deck: deck)),
                                ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.quiz_rounded,
                        label: 'Take Quiz',
                        color: const Color(0xFF34D399),
                        onTap: deck.quizQuestions.isEmpty
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          QuizScreen(deck: deck)),
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Flashcards (${deck.flashcards.length})',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final card = deck.flashcards[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(card.front,
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const Divider(color: Colors.white10, height: 16),
                        Text(card.back,
                            style: GoogleFonts.outfit(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  );
                },
                childCount: deck.flashcards.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;
  const _InfoBadge({required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.outfit(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
            Text(sub,
                style:
                    GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.white.withOpacity(0.04) : color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: onTap == null ? Colors.white24 : Colors.white,
                size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.outfit(
                    color:
                        onTap == null ? Colors.white24 : Colors.white,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
