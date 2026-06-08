import 'package:hive/hive.dart';
import 'flashcard_model.dart';
import 'quiz_question_model.dart';

part 'study_deck_model.g.dart';

@HiveType(typeId: 0)
class StudyDeck extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime createdAt;

  /// FlashCards stored as JSON strings — avoids nested HiveObject issues
  @HiveField(3)
  List<String> flashcardJsonList;

  /// QuizQuestions stored as JSON strings
  @HiveField(4)
  List<String> quizQuestionJsonList;

  @HiveField(5)
  List<DateTime> reviewHistory;

  StudyDeck({
    required this.id,
    required this.title,
    DateTime? createdAt,
    List<String>? flashcardJsonList,
    List<String>? quizQuestionJsonList,
    List<DateTime>? reviewHistory,
  })  : createdAt = createdAt ?? DateTime.now(),
        flashcardJsonList = flashcardJsonList ?? [],
        quizQuestionJsonList = quizQuestionJsonList ?? [],
        reviewHistory = reviewHistory ?? [];

  List<FlashCard> get flashcards =>
      flashcardJsonList.map(FlashCard.fromJsonString).toList();

  set flashcards(List<FlashCard> cards) {
    flashcardJsonList = cards.map((c) => c.toJsonString()).toList();
  }

  List<QuizQuestion> get quizQuestions =>
      quizQuestionJsonList.map(QuizQuestion.fromJsonString).toList();

  set quizQuestions(List<QuizQuestion> qs) {
    quizQuestionJsonList = qs.map((q) => q.toJsonString()).toList();
  }

  int get totalCards => flashcardJsonList.length;

  int get dueToday => flashcards.where((c) => c.isDueToday).length;

  double get overallAccuracy {
    final cards = flashcards;
    if (cards.isEmpty) return 0.0;
    final total = cards.fold<int>(0, (s, c) => s + c.totalReviews);
    final correct = cards.fold<int>(0, (s, c) => s + c.correctReviews);
    return total == 0 ? 0.0 : correct / total;
  }

  void updateCard(FlashCard updated) {
    flashcardJsonList = flashcards.map((c) {
      return c.id == updated.id ? updated.toJsonString() : c.toJsonString();
    }).toList();
  }
}
