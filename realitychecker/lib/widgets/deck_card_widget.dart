import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/study_deck_model.dart';

class DeckCardWidget extends StatelessWidget {
  final StudyDeck deck;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DeckCardWidget({
    super.key,
    required this.deck,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = deck.totalCards == 0
        ? 0.0
        : (deck.totalCards - deck.dueToday) / deck.totalCards;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glow accent
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF818CF8).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deck.title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white54, size: 20),
                        color: const Color(0xFF16213E),
                        onSelected: (val) {
                          if (val == 'delete') onDelete();
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 18),
                                const SizedBox(width: 8),
                                Text('Delete',
                                    style:
                                        GoogleFonts.outfit(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Chip(
                        icon: Icons.style_rounded,
                        label: '${deck.totalCards} cards',
                        color: const Color(0xFF818CF8),
                      ),
                      const SizedBox(width: 8),
                      if (deck.dueToday > 0)
                        _Chip(
                          icon: Icons.notifications_active_rounded,
                          label: '${deck.dueToday} due',
                          color: const Color(0xFFFBBF24),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearPercentIndicator(
                    percent: progress.clamp(0.0, 1.0),
                    lineHeight: 6,
                    backgroundColor: Colors.white12,
                    progressColor: const Color(0xFF818CF8),
                    barRadius: const Radius.circular(8),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress * 100).toInt()}% reviewed',
                    style: GoogleFonts.outfit(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
