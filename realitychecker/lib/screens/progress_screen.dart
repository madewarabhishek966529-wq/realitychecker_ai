import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/hive_storage_service.dart';
import '../models/flashcard_model.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyData = HiveStorageService.getWeeklyReviewHistory();
    final weakCards = HiveStorageService.getWeakCards(limit: 5);
    final entries = weeklyData.entries.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: Text('Progress',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Weekly Reviews',
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: weeklyData.values.every((v) => v == 0)
                ? Center(
                    child: Text(
                      'No reviews yet this week',
                      style: GoogleFonts.outfit(color: Colors.white38),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (weeklyData.values
                                  .reduce((a, b) => a > b ? a : b) +
                              2)
                          .toDouble(),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (val, _) => Text(
                              val.toInt().toString(),
                              style: GoogleFonts.outfit(
                                  color: Colors.white38, fontSize: 11),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) {
                              final idx = val.toInt();
                              if (idx < 0 || idx >= entries.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  DateFormat('E')
                                      .format(entries[idx].key),
                                  style: GoogleFonts.outfit(
                                      color: Colors.white54,
                                      fontSize: 11),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.white10,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(entries.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: entries[i].value.toDouble(),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF818CF8),
                                  Color(0xFFA78BFA)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: 24,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
          const SizedBox(height: 28),
          Text('Weakest Cards',
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (weakCards.isEmpty)
            Text('No cards yet. Start reviewing!',
                style: GoogleFonts.outfit(color: Colors.white38))
          else
            ...weakCards
                .map((c) => _WeakCardTile(card: c))
                .toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _WeakCardTile extends StatelessWidget {
  final FlashCard card;
  const _WeakCardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    final ef = card.easeFactor;
    final Color color = ef < 1.8
        ? Colors.redAccent
        : ef < 2.2
            ? const Color(0xFFFBBF24)
            : const Color(0xFF34D399);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'EF\n${ef.toStringAsFixed(1)}',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    color: color, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.front,
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${card.totalReviews} reviews · '
                    '${(card.accuracy * 100).toInt()}% accuracy',
                    style: GoogleFonts.outfit(
                        color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
