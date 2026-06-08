import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/study_deck_model.dart';
import '../services/hive_storage_service.dart';
import '../widgets/deck_card_widget.dart';
import '../widgets/stat_card_widget.dart';
import 'import_screen.dart';
import 'deck_detail_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StudyDeck> _decks = [];

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  void _loadDecks() {
    setState(() {
      _decks = HiveStorageService.getAllDecks();
    });
  }

  Future<void> _deleteDeck(StudyDeck deck) async {
    await HiveStorageService.deleteDeck(deck.id);
    _loadDecks();
  }

  @override
  Widget build(BuildContext context) {
    final totalDecks = _decks.length;
    final totalDue = HiveStorageService.getTotalDueToday();
    final totalCards =
        _decks.fold<int>(0, (sum, d) => sum + d.totalCards);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A1A),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Study AI',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF0A0A1A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProgressScreen()),
                  );
                },
              ),
              IconButton(
                icon:
                    const Icon(Icons.settings_rounded, color: Colors.white70),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats
                Row(
                  children: [
                    Expanded(
                      child: StatCardWidget(
                        label: 'Decks',
                        value: '$totalDecks',
                        icon: Icons.layers_rounded,
                        color: const Color(0xFF818CF8),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideX(begin: -0.1, end: 0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCardWidget(
                        label: 'Due Today',
                        value: '$totalDue',
                        icon: Icons.notifications_active_rounded,
                        color: const Color(0xFFFBBF24),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideX(begin: -0.1, end: 0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCardWidget(
                        label: 'Cards',
                        value: '$totalCards',
                        icon: Icons.style_rounded,
                        color: const Color(0xFF34D399),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideX(begin: -0.1, end: 0),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Your Decks',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                if (_decks.isEmpty) _buildEmptyState(),
              ]),
            ),
          ),
          if (_decks.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: DeckCardWidget(
                      deck: _decks[i],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DeckDetailScreen(deck: _decks[i]),
                          ),
                        );
                        _loadDecks();
                      },
                      onDelete: () => _deleteDeck(_decks[i]),
                    )
                        .animate()
                        .fadeIn(delay: (i * 80).ms)
                        .slideY(begin: 0.05, end: 0),
                  ),
                  childCount: _decks.length,
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ImportScreen()),
          );
          _loadDecks();
        },
        backgroundColor: const Color(0xFF818CF8),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'New Deck',
          style: GoogleFonts.outfit(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories_rounded,
              color: Color(0xFF818CF8), size: 56),
          const SizedBox(height: 16),
          Text(
            'No decks yet',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "New Deck" to import a PDF\nor paste your study notes',
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}
