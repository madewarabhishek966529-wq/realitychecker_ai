import 'dart:convert';

class FlashCard {
  String id;
  String front;
  String back;
  DateTime dueDate;
  double easeFactor;
  int interval;
  int repetitions;
  int totalReviews;
  int correctReviews;

  FlashCard({
    required this.id,
    required this.front,
    required this.back,
    DateTime? dueDate,
    this.easeFactor = 2.5,
    this.interval = 1,
    this.repetitions = 0,
    this.totalReviews = 0,
    this.correctReviews = 0,
  }) : dueDate = dueDate ?? DateTime.now();

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day + 1));
  }

  double get accuracy =>
      totalReviews == 0 ? 0.0 : correctReviews / totalReviews;

  Map<String, dynamic> toJson() => {
        'id': id,
        'front': front,
        'back': back,
        'dueDate': dueDate.toIso8601String(),
        'easeFactor': easeFactor,
        'interval': interval,
        'repetitions': repetitions,
        'totalReviews': totalReviews,
        'correctReviews': correctReviews,
      };

  factory FlashCard.fromJson(Map<String, dynamic> j) => FlashCard(
        id: j['id'] as String,
        front: j['front'] as String,
        back: j['back'] as String,
        dueDate: DateTime.parse(j['dueDate'] as String),
        easeFactor: (j['easeFactor'] as num).toDouble(),
        interval: j['interval'] as int,
        repetitions: j['repetitions'] as int,
        totalReviews: j['totalReviews'] as int,
        correctReviews: j['correctReviews'] as int,
      );

  static FlashCard fromJsonString(String s) =>
      FlashCard.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());
}
