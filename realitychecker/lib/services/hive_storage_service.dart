import 'package:hive_flutter/hive_flutter.dart';
import '../models/flashcard_model.dart';
import '../models/study_deck_model.dart';

class HiveStorageService {
  static const String _deckBoxName = 'study_decks';

  static Box<StudyDeck> get _deckBox => Hive.box<StudyDeck>(_deckBoxName);

  static Future<void> init() async {
    await Hive.openBox<StudyDeck>(_deckBoxName);
  }

  static List<StudyDeck> getAllDecks() {
    return _deckBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> saveDeck(StudyDeck deck) async {
    await _deckBox.put(deck.id, deck);
  }

  static Future<void> deleteDeck(String id) async {
    await _deckBox.delete(id);
  }

  static StudyDeck? getDeck(String id) => _deckBox.get(id);

  /// Persist deck after mutation (updateCard / adding review dates)
  static Future<void> updateDeck(StudyDeck deck) async {
    await deck.save();
  }

  static int getTotalDueToday() {
    return getAllDecks().fold<int>(0, (sum, d) => sum + d.dueToday);
  }

  static Map<DateTime, int> getWeeklyReviewHistory() {
    final now = DateTime.now();
    final result = <DateTime, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      result[day] = 0;
    }
    for (final deck in getAllDecks()) {
      for (final date in deck.reviewHistory) {
        final day = DateTime(date.year, date.month, date.day);
        if (result.containsKey(day)) {
          result[day] = result[day]! + 1;
        }
      }
    }
    return result;
  }

  static List<FlashCard> getWeakCards({int limit = 10}) {
    final allCards =
        getAllDecks().expand((d) => d.flashcards).toList();
    allCards.sort((a, b) => a.easeFactor.compareTo(b.easeFactor));
    return allCards.take(limit).toList();
  }
}
