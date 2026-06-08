import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/study_deck_model.dart';
import '../models/flashcard_model.dart';
import '../services/spaced_repetition_service.dart';
import '../services/hive_storage_service.dart';
import '../widgets/flip_card_widget.dart';

class FlashCardScreen extends StatefulWidget {
  final StudyDeck deck;

  const FlashCardScreen({super.key, required this.deck});

  @override
  State<FlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  late List<FlashCard> _cards;
  late StudyDeck _deck;
  int _currentIndex = 0;
  bool _showBack = false;
  int _reviewed = 0;

  @override
  void initState() {
    super.initState();
    _deck = widget.deck;
    // Prioritise due cards first
    _cards = _deck.flashcards
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  FlashCard get _current => _cards[_currentIndex];
  bool get _isDone => _currentIndex >= _cards.length;

  void _flip() => setState(() => _showBack = !_showBack);

  Future<void> _rate(ReviewQuality quality) async {
    final updated = SpacedRepetitionService.processReview(_current, quality);

    // Update the card in the deck and persist
    _deck.updateCard(updated);
    _deck.reviewHistory.add(DateTime.now());
    await HiveStorageService.updateDeck(_deck);

    setState(() {
      _reviewed++;
      _showBack = false;
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: Text(
          _deck.title,
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _isDone
                    ? 'Done!'
                    : '${_currentIndex + 1}/${_cards.length}',
                style:
                    GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: _isDone ? _buildDoneScreen() : _buildCardScreen(),
    );
  }

  Widget _buildCardScreen() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _cards.isEmpty ? 0 : _currentIndex / _cards.length,
          backgroundColor: Colors.white10,
          valueColor:
              const AlwaysStoppedAnimation(Color(0xFF818CF8)),
          minHeight: 3,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FlipCardWidget(
              key: ValueKey(_currentIndex),
              front: _current.front,
              back: _current.back,
              showBack: _showBack,
              onTap: _flip,
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showBack
              ? _buildRatingButtons()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _flip,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF818CF8)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.flip_rounded,
                          color: Color(0xFF818CF8)),
                      label: Text('Show Answer',
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF818CF8),
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRatingButtons() {
    final ratings = [
      (ReviewQuality.again, Colors.redAccent, Icons.replay_rounded),
      (ReviewQuality.hard, Colors.orange, Icons.sentiment_neutral_rounded),
      (ReviewQuality.good, const Color(0xFF818CF8), Icons.thumb_up_rounded),
      (ReviewQuality.easy, const Color(0xFF34D399), Icons.star_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Row(
        children: ratings.map((r) {
          final (quality, color, icon) = r;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => _rate(quality),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Icon(icon, color: color, size: 22),
                      const SizedBox(height: 4),
                      Text(quality.label,
                          style: GoogleFonts.outfit(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      )
          .animate()
          .fadeIn(duration: 250.ms)
          .slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildDoneScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration_rounded,
                  color: Color(0xFF818CF8), size: 72)
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text('Session Complete!',
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text('You reviewed $_reviewed cards',
              style:
                  GoogleFonts.outfit(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF818CF8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            label: Text('Back to Home',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
